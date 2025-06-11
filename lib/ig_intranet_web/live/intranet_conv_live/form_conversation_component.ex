defmodule IgIntranetWeb.IntranetConvLive.FormConversationComponent do
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

      <.simple_form
        for={@form_conv}
        id="intranet_conversation-form"
        phx-submit="save_conversation"
        phx-target={@myself}
      >
        <.input
          field={@form_conv[:conversation_topic]}
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
          field={@form_conv[:user_list]}
        />
        <input type="hidden" name="intranet_conversation[conversation_type]" value="private" />
        <input type="hidden" name="intranet_conversation[conversation_status]" value="active" />
        <.inputs_for :let={mess} field={@form_conv[:intranet_messages]}>
          <.input
            field={mess[:message_body]}
            type="text"
            label="Nouveau message"
            placeholder="Démarrez votre conversation"
          />
        </.inputs_for>
        <:actions>
          <.button phx-disable-with="Saving...">Save  message</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{current_user: current_user}, socket) do
    users = Accounts.list_users_tuple_except_user_id(current_user.id)

    {:ok,
     socket
     |> assign(other_users_list: users)
     |> assign(current_user: current_user)
     |> assign_form()}
  end

  defp assign_form(socket) do
    form =
      %IntranetConversation{intranet_messages: [%IntranetMessage{}]}
      |> Chats.change_intranet_conversation()
      |> to_form()

    socket
    |> assign(:form_conv, form)
  end

  @impl true
  def handle_event(
        "save_conversation",
        %{"intranet_conversation" => intranet_conversation_params},
        %{assigns: %{current_user: current_user}} = socket
      ) do
    # on ajoute ici le user_id (créateur du message) pour éivter une manipulation malveillante dans le formulaire.
    intranet_conversation_params
    |> Kernel.put_in(["intranet_messages", "0", "user_id"], current_user.id)
    |> Chats.create_intranet_conversation_with_users_with_log(current_user)
    |> case do
      {:ok, %{log: _log, conversation: conversation}} ->
        updated_conversation =
          conversation.id
          |> Chats.get_intranet_conversation_with_preload!()

        {:noreply,
         socket
         |> assign(current_conversation: updated_conversation)
         |> put_flash(:info, "Conversation créée !")
         |> push_patch(to: ~p"/intranet_conv")}

      {:error, _name, changeset} ->
        {
          :noreply,
          assign(socket, form: to_form(changeset))
          |> push_patch(to: ~p"/intranet_conv/new_conv")
          |> put_flash(:error_handler, "There has been an error")
        }
    end
  end
end
