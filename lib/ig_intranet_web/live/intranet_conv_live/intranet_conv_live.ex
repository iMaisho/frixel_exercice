defmodule IgIntranetWeb.IntranetConvLive do
  use IgIntranetWeb, :live_view

  alias IgIntranet.Chats
  alias IgIntranet.Chats.IntranetMessage

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    if connected?(socket), do: Chats.message_subscribe()

    conversations = Chats.list_intranet_conversations_with_preload_by_user_id(current_user.id)

    {:ok,
     socket
     |> assign(conversations: conversations)
     |> assign(:select_form, %{})
     |> assign(:current_conversation_id, 0)}
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

  # TODO: implémenter l'édit du topic de la conversation
  #   defp apply_action(socket, :edit_conv, _params) do
  #   conversation =
  #     Chats.get_intranet_conversation!(String.to_integer(socket.assigns.current_conversation_id))

  #   socket
  #   |> assign(:page_title, "Edit Intranet conversation")
  #   |> assign(
  #     :intranet_conversation,
  #     conversation
  #   )
  # end

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
        %{"intranet_message" => message_params},
        %{
          assigns: %{current_user: current_user, current_conversation_id: current_conversation_id}
        } = socket
      ) do
    message_params
    |> Map.merge(%{
      "user_id" => current_user.id,
      "intranet_conversation_id" => current_conversation_id
    })
    |> Chats.create_intranet_message()
    |> case do
      {:ok, message} ->
        {:noreply,
         socket
         |> update(:messages, &[message | &1])
         |> put_flash(:info, "Message créé !")
         |> push_patch(to: ~p"/intranet_conv")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         assign(socket, form_mess: to_form(changeset)) |> push_patch(to: ~p"/intranet_conv")}
    end
  end

  @impl true
  def handle_event(
        "save",
        %{"intranet_conversation" => intranet_conversation_params},
        %{assigns: %{current_user: current_user}} = socket
      ) do
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
         |> push_patch(to: ~p"/intranet_conv")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         assign(socket, form: to_form(changeset)) |> push_patch(to: ~p"/intranet_conv/new_conv")}
    end
  end

  @impl true
  def handle_event("select", %{"current_conversation_id" => id}, socket) do
    messages =
      Chats.list_intranet_message_by_conversation_id_with_preload(id)

    {:noreply,
     socket
     |> assign(:messages, messages)
     |> assign(:current_conversation_id, id)}
  end
end
