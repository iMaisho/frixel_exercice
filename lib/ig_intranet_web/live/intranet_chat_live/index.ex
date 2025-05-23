defmodule IgIntranetWeb.IntranetChatLive.Index do
  use IgIntranetWeb, :live_view

  alias IgIntranet.Chats
  alias IgIntranet.Chats.IntranetMessage

  @impl true
  def mount(_params, _session, socket) do
    new_socket =
      socket
      |> assign(:intranet_messages, Chats.list_intranet_message_with_preload())
      |> assign(:intranet_conversations, Chats.list_intranet_conversation_with_preload())
      |> assign(:filter_form, %{})
      |> assign(:current_conversation_id, 0)

    if connected?(socket), do: Chats.subscribe()

    {:ok, new_socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    intranet_messages =
      Chats.list_intranet_message_by_conversation_id(socket.assigns.current_conversation_id)

    socket |> assign(:intranet_messages, intranet_messages)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:intranet_message, %IntranetMessage{})
  end

  @impl true
  def handle_info({:message_created, _message}, socket) do
    intranet_messages =
      Chats.list_intranet_message_by_conversation_id(socket.assigns.current_conversation_id)

    {:noreply, socket |> assign(:intranet_messages, intranet_messages)}
  end

  @impl true
  def handle_info(
        {IgIntranetWeb.IntranetMessageLive.FormComponent, {:saved, intranet_message}},
        socket
      ) do
    if(
      socket.assigns.current_user.id == intranet_message.sender_id ||
        socket.assigns.current_conversation_id != intranet_message.intranet_conversation_id
    ) do
      {:noreply, socket}
    else
      {:noreply,
       socket
       |> assign(:intranet_messages, intranet_message)}
    end
  end

  @impl true
  def handle_event("filter", %{"current_conversation_id" => id}, socket) do
    intranet_messages =
      Chats.list_intranet_message_by_conversation_id(id)

    {:noreply,
     socket
     |> assign(:intranet_messages, intranet_messages)
     |> assign(:current_conversation_id, id)}
  end
end
