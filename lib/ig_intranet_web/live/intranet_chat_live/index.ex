defmodule IgIntranetWeb.IntranetChatLive.Index do
  use IgIntranetWeb, :live_view

  alias IgIntranet.Chats
  alias IgIntranet.Chats.IntranetMessage

  @impl true
  def mount(_params, _session, socket) do
    # {:ok, {intranet_conversations, meta}} = Chats.list_conversations_with_flop(params)
    # conversation_topics =
    #   Enum.map(intranet_conversations, fn conversation -> conversation.conversation_topic end)

    # {
    #   :ok,
    #   socket
    #   |> assign(:intranet_conversations, intranet_conversations)
    #   |> assign(:conversation_topics, conversation_topics)
    #   |> assign(:meta, meta)
    # }
    if connected?(socket), do: Chats.subscribe()
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    {:ok, {intranet_messages, meta}} = Chats.list_messages_with_flop(params)

    socket
    |> assign(:meta, meta)
    |> assign(:intranet_messages, intranet_messages)
  end

  defp apply_action(socket, :new, _params) do
    intranet_conversations = Chats.list_intranet_conversation_with_preload()

    socket
    |> assign(:page_title, "New Intranet message")
    |> assign(:intranet_conversations, intranet_conversations)
    |> assign(:intranet_message, %IntranetMessage{})
  end

  @impl true
  def handle_info({:message_created, message}, socket) do
    updated =
      [message | socket.assigns.intranet_messages]
      |> Enum.uniq_by(& &1.id)

    {:noreply, assign(socket, :intranet_messages, updated)}
  end

  @impl true
  def handle_info(
        {IgIntranetWeb.IntranetMessageLive.FormComponent, {:saved, _intranet_message}},
        socket
      ) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    {:noreply, push_patch(socket, to: ~p"/intranet_chat?#{params}")}
  end
end
