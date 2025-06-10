defmodule IgIntranetWeb.IntranetConvLive do
  use IgIntranetWeb, :live_view

  alias IgIntranet.Chats

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    if connected?(socket), do: Chats.message_subscribe()

    available_conversations =
      Chats.list_intranet_conversations_with_preload_by_user_id(current_user.id)

    {:ok,
     socket
     |> assign(available_conversations: available_conversations)
     |> assign(:select_form, %{})
     |> assign(:current_conversation, nil)}
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

  defp apply_action(socket, :edit_conv, %{"id" => id}) do
    current_conversation = Chats.get_intranet_conversation_with_preload!(id)

    socket
    |> assign(:page_title, "Edit Intranet conversation")
    |> assign(:current_conversation, current_conversation)
  end

  defp apply_action(socket, :edit_mess, %{"message_id" => id}) do
    selected_message = Chats.get_intranet_message!(id)

    socket |> assign(:message, selected_message)
  end

  defp apply_action(socket, :confirm_delete_mess, %{"message_id" => id}) do
    selected_message = Chats.get_intranet_message!(id)

    socket |> assign(:message, selected_message)
  end

  @impl true
  def handle_info({:message_created, message}, %{assigns: %{current_user: current_user}} = socket) do
    if current_user.id != message.user_id do
      message =
        message |> Chats.preload_intranet_message_with_user()

      updated_conversation =
        message.intranet_conversation_id
        |> Chats.get_intranet_conversation_with_preload!()

      {:noreply,
       socket
       |> assign(current_conversation: updated_conversation)
       |> put_flash(:info, "Message reçu !")}
    else
      {:noreply, socket}
    end
  end

  def handle_info(
        {IgIntranetWeb.IntranetConvLive.FormEditConversationComponent, {:edited, conversation}},
        socket
      ) do
    updated =
      Chats.get_intranet_conversation_with_preload!(conversation.id)

    {:noreply, socket |> assign(:current_conversation, updated)}
  end

  def handle_info(
        {IgIntranetWeb.IntranetConvLive.FormMessageComponent, {:update_messages, message}},
        socket
      ) do
    updated_conversation =
      Chats.get_intranet_conversation_with_preload!(message.intranet_conversation_id)

    {:noreply,
     socket
     |> assign(current_conversation: updated_conversation)}
  end

  @impl true
  def handle_event("select", %{"current_conversation" => ""}, socket) do
    {:noreply, socket |> assign(:current_conversation, nil)}
  end

  def handle_event("select", %{"current_conversation" => id}, socket) do
    conversation =
      id
      |> Chats.get_intranet_conversation_with_preload!()

    {:noreply, socket |> assign(:current_conversation, conversation)}
  end

  def handle_event("delete_message", _params, socket) do
    IO.inspect(socket.assigns.message)
    Chats.delete_intranet_message(socket.assigns.message)

    updated =
      Chats.get_intranet_conversation_with_preload!(
        socket.assigns.message.intranet_conversation_id
      )

    {:noreply,
     socket
     |> assign(:current_conversation, updated)
     |> push_patch(to: ~p"/intranet_conv")
     |> put_flash(:info, "Message supprimé !")}
  end
end
