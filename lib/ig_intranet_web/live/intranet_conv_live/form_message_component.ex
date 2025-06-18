defmodule IgIntranetWeb.IntranetConvLive.FormMessageComponent do
  use IgIntranetWeb, :live_component

  alias IgIntranet.Accounts
  alias IgIntranet.Chats
  alias IgIntranet.Chats.IntranetMessage

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex-row">
        <.simple_form
          for={@form_mess}
          id="intranet_message_form"
          phx-change="check_body"
          phx-submit="save_message"
          phx-target={@myself}
        >
          <.input
            field={@form_mess[:message_body]}
            type="text"
            placeholder="Send a message here"
            class="basis-128"
          />
          <.input
            :if={@arobase?}
            field={@form_mess[:user_list]}
            type="select"
            prompt="Mention a user"
            options={@arobase_users}
          />
          <div class="flex">
            <div class="relative w-[30px] h-[30px] cursor-pointer">
              <.live_file_input
                upload={@uploads.file}
                class="absolute top-0 left-0 z-2 w-full h-full opacity-0"
              />
              <img
                src="/images/trombone.svg"
                class="absolute top-0 left-0 z-1 w-full h-full pointer-events-none"
              />
            </div>
            <ul>
              <%= for entry <- @uploads.file.entries do %>
                <li>
                  {entry.client_name}
                  <button
                    type="button"
                    phx-click="cancel_upload"
                    phx-value-ref={entry.ref}
                    data-phx-upload-ref={entry.ref}
                    phx-target={@myself}
                  >
                    Cancel
                  </button>
                </li>
              <% end %>
            </ul>
          </div>

          <.button class="basis-128">Send</.button>
        </.simple_form>
      </div>
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
     |> assign(users: users)
     |> assign(available_conversations: available_conversations)
     |> assign(current_conversation: current_conversation)
     |> assign(current_user: current_user)
     |> assign(message: message)
     |> assign(action: action)
     |> assign(arobase?: false)
     |> assign(arobase_users: users)
     |> assign(:uploaded_files, [])
     |> allow_upload(:file, accept: ~w(.jpg .jpeg .png), max_entries: 1)
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

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, socket |> cancel_upload(:file, ref)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
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
           assigns: %{
             current_user: current_user,
             current_conversation: current_conversation
           }
         } = socket,
         :index,
         message_params
       ) do
    [{path, name} | _rest] =
      consume_uploaded_entries(socket, :file, fn %{path: path}, entry ->
        name = Path.basename(path)

        dest =
          Path.join(Application.app_dir(:ig_intranet, "priv/static/uploads"), name)

        # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
        File.cp!(path, dest)

        # {:ok, %{path: dest, name: entry.client_name}}
        {:ok, {~p"/uploads/#{Path.basename(dest)}", entry.client_name}}
      end)

    attrs = %{path: path, name: name}

    message_params =
      message_params
      |> Map.merge(%{
        "user_id" => current_user.id,
        "intranet_conversation_id" => current_conversation.id,
        "meta_data" => %{"uploaded_file" => attrs}
      })

    case Chats.create_intranet_message(message_params) do
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
        {:noreply, assign(socket, form_mess: to_form(changeset))}
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

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
