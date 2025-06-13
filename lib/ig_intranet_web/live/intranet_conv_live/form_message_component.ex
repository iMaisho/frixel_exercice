defmodule IgIntranetWeb.IntranetConvLive.FormMessageComponent do
  use IgIntranetWeb, :live_component

  alias IgIntranet.Accounts
  alias IgIntranet.Chats
  alias IgIntranet.Chats.IntranetMessage

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form_mess}
        id="intranet_message-form"
        phx-change="check_body"
        phx-submit="save_message"
        phx-target={@myself}
      >
        <.input field={@form_mess[:message_body]} type="text" placeholder="Send a message here" />
        <.input
          :if={@arobase?}
          field={@form_mess[:user_list]}
          type="select"
          prompt="Send a message here"
          options={@arobase_users}
        />
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(
        %{
          current_user: current_user,
          current_conversation: current_conversation,
          message: message,
          action: action
        },
        socket
      ) do
    available_conversations = Chats.list_intranet_conversation_tuple_by_user_id(current_user.id)

    users = Accounts.list_users_tuple_except_user_id(current_user.id)

    {:ok,
     socket
     |> assign(available_conversations: available_conversations)
     |> assign(users: users)
     |> assign(current_conversation: current_conversation)
     |> assign(current_user: current_user)
     |> assign(message: message)
     |> assign(action: action)
     |> assign(arobase?: false)
     |> assign(arobase_users: users)
     |> assign_form()}
  end

  @impl true
  def handle_event(
        "check_body",
        %{"intranet_message" => %{"message_body" => content}},
        %{
          assigns: %{
            current_conversation: _current_conversation,
            current_user: user,
            users: users
          }
        } = socket
      ) do
    # Vérifie si le formulaire d'envoi de message contient un @
    if content |> String.contains?("@") do
      # Quand un @ est trouvé, afficher un select avec les utilisateurs de la conversation

      [_before, mention] = String.split(content, "@")

      users_filtered =
        Accounts.list_users_tuple_except_user_id_by_mention(user.id, mention)

      {:noreply,
       socket
       |> assign(arobase?: true)
       |> assign(arobase_users: users_filtered)}
    else
      {:noreply,
       socket
       |> assign(arobase?: false)
       |> assign(arobase_users: users)}
    end

    #   # verify_mention
    #   # add_to_metadata
    # end
  end

  @impl true

  def handle_event("save_message", %{"intranet_message" => message_params}, socket) do
    save_message(socket, socket.assigns.action, message_params)
  end

  defp save_message(
         %{
           assigns: %{message: message}
         } = socket,
         :edit_mess,
         message_params
       ) do
    Chats.update_intranet_message(message, message_params)
    |> case do
      {:ok, message} ->
        updated_conversation =
          message.intranet_conversation_id
          |> Chats.get_intranet_conversation_with_preload!()

        notify_parent({:update_messages, message})

        {:noreply,
         socket
         |> assign(current_conversation: updated_conversation)
         |> put_flash(:info, "Message modifié !")
         |> push_patch(to: ~p"/intranet_conv")
         |> reset_form()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(form_mess: to_form(changeset))}
    end
  end

  defp save_message(
         %{
           assigns: %{current_user: current_user, current_conversation: current_conversation}
         } = socket,
         :index,
         message_params
       ) do
    message_params
    |> Map.merge(%{
      "user_id" => current_user.id,
      "intranet_conversation_id" => current_conversation.id
    })
    |> Chats.create_intranet_message()
    |> case do
      {:ok, message} ->
        updated_conversation =
          message.intranet_conversation_id
          |> Chats.get_intranet_conversation_with_preload!()

        notify_parent({:update_messages, message})

        {:noreply,
         socket
         |> assign(current_conversation: updated_conversation)
         |> put_flash(:info, "Message créé !")
         |> reset_form()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(form_mess: to_form(changeset))}
    end
  end

  defp assign_form(%{assigns: %{message: message}} = socket) do
    form =
      message
      |> Chats.change_intranet_message()
      |> to_form()

    socket
    |> assign(:form_mess, form)
  end

  defp reset_form(socket) do
    new_form =
      %IntranetMessage{}
      |> Chats.change_intranet_message()
      |> to_form()

    socket
    |> assign(:form_mess, new_form)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
