defmodule IgIntranetWeb.IntranetChatLive do
  use IgIntranetWeb, :live_view

  alias IgIntranet.Chats
  alias IgIntranet.Chats.IntranetMessage

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    if connected?(socket), do: Chats.message_subscribe()

    messages = Chats.list_intranet_messages_with_preload_by_user_id(current_user.id)

    {:ok,
     socket
     |> assign(messages: messages)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  defp apply_action(socket, :new, _params) do
    socket
  end

  defp apply_action(socket, :new_conv, _params) do
    socket
  end

  @impl true
  def handle_info({:message_created, message}, %{assigns: %{current_user: current_user}} = socket) do
    if current_user.id != message.user_id do
      message =
        message |> Chats.preload_intranet_message_with_user()

      {:noreply,
       socket
       |> update(:messages, &[message | &1])
       |> put_flash(:info, "Message reçu !")}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event(
        "save",
        %{"intranet_message" => intranet_message_params},
        %{assigns: %{current_user: current_user}} = socket
      ) do
    intranet_message_params
    |> Map.merge(%{"user_id" => current_user.id})
    |> Chats.create_intranet_message()
    |> case do
      {:ok, message} ->
        {:noreply,
         socket
         |> update(:messages, &[message | &1])
         |> put_flash(:info, "Message créé !")
         |> push_patch(to: ~p"/intranet_chat")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         assign(socket, form: to_form(changeset)) |> push_patch(to: ~p"/intranet_chat/new")}
    end
  end

  @impl true
  def handle_event(
        "save",
        %{"intranet_conversation" => intranet_conversation_params},
        %{assigns: %{current_user: current_user}} = socket
      ) do
    IO.inspect(current_user)

    # on ajoute ici le user_id (créateur du message) pour éivter une manipulation malveillante dans le formulaire.
    intranet_conversation_params
    |> Kernel.put_in(["intranet_messages", "0", "user_id"], current_user.id)
    |> Chats.create_intranet_conversation_with_users(current_user)
    |> case do
      {:ok, conversation} ->
        first_and_only_message =
          conversation
          |> Chats.preload_intranet_conversation_with_message()
          |> Map.get(:intranet_messages)
          |> List.first()

        {:noreply,
         socket
         |> update(:messages, &[first_and_only_message | &1])
         |> put_flash(:info, "Message créé !")
         |> push_patch(to: ~p"/intranet_chat")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         assign(socket, form: to_form(changeset)) |> push_patch(to: ~p"/intranet_chat/new_conv")}
    end
  end
end

defmodule IgIntranetWeb.IntranetChatLive.FormComponent do
  use IgIntranetWeb, :live_component

  alias IgIntranet.Chats.IntranetMessage
  alias IgIntranet.Accounts
  alias IgIntranet.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Nouveau message
      </.header>

      <.link patch={~p"/intranet_chat/new_conv"}>
        <div class="grid justify-items-stretch">
          <.button class="justify-self-end">{gettext("New conversation")}</.button>
        </div>
      </.link>
      <.simple_form for={@form} id="intranet_message-form" phx-submit="save">
        <.input
          field={@form[:intranet_conversation_id]}
          type="select"
          label="Conversation rattachée"
          options={@intranet_conversations}
          prompt="Select a conversation"
        />
        <.input
          field={@form[:recipient_id]}
          type="select"
          label="Destinataire"
          options={@users}
          prompt="Select a user"
        />
        <.input field={@form[:message_body]} type="text" label="Message body" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Intranet message</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user_id: user_id}, socket) do
    intranet_conversations = Chats.list_intranet_conversation_tuple_by_user_id(user_id)

    users = Accounts.list_users_tuple_except_user_id(user_id)

    {:ok,
     socket
     |> assign(intranet_conversations: intranet_conversations)
     |> assign(users: users)
     |> assign_form()}
  end

  defp assign_form(socket) do
    form =
      %IntranetMessage{}
      |> Chats.change_intranet_message()
      |> to_form()

    socket
    |> assign(:form, form)
  end
end

defmodule IgIntranetWeb.IntranetChatLive.FormConversationComponent do
  use IgIntranetWeb, :live_component

  alias IgIntranet.Chats.IntranetConversation
  alias IgIntranet.Chats.IntranetMessage
  alias IgIntranet.Accounts
  alias IgIntranet.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Nouveau message
      </.header>

      <.simple_form for={@form} id="intranet_conversation-form" phx-submit="save">
        <.input
          field={@form[:conversation_topic]}
          label="Topic"
          type="text"
          placeholder="Titre de votre conversation"
          required
        />
        <.input
          type="select"
          multiple
          label="Recipients"
          required
          options={@other_users_list}
          field={@form[:user_list]}
        />
        <input type="hidden" name="intranet_conversation[conversation_type]" value="private" />
        <input type="hidden" name="intranet_conversation[conversation_status]" value="active" />
        <.inputs_for :let={mess} field={@form[:intranet_messages]}>
          <.input
            field={mess[:message_body]}
            type="text"
            label="Nouveau message"
            placeholder="Démarrez votre conversation"
          />
          <%!-- <.input
            field={mess[:recipient_id]}
            type="select"
            label="Destinataire"
            options={@users}
            prompt="Select a user"
          /> --%>
        </.inputs_for>
        <:actions>
          <.button phx-disable-with="Saving...">Save  message</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user_id: user_id}, socket) do
    users = Accounts.list_users_tuple_except_user_id(user_id)

    {:ok,
     socket
     |> assign(other_users_list: users)
     |> assign_form()}
  end

  defp assign_form(socket) do
    form =
      %IntranetConversation{intranet_messages: [%IntranetMessage{}]}
      |> Chats.change_intranet_conversation()
      |> to_form()

    socket
    |> assign(:form, form)
  end
end
