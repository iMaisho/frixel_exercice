defmodule IgIntranetWeb.IntranetMessageLive.Index do
  use IgIntranetWeb, :live_view
  import Flop.Phoenix

  alias IgIntranet.Chats
  alias IgIntranet.Chats.IntranetMessage

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :intranet_messages, Chats.list_intranet_message_with_preload())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:ok, {messages, meta}} = Chats.flop_list_intranet_messages(params)

    {:noreply,
     socket
     |> assign(messages: messages, meta: meta)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    intranet_conversations = Chats.list_intranet_conversation_with_preload()

    socket
    |> assign(:page_title, "Edit Intranet message")
    |> assign(:intranet_conversations, intranet_conversations)
    |> assign(:intranet_message, Chats.get_intranet_message_with_preload!(id))
  end

  defp apply_action(socket, :new, _params) do
    intranet_conversations = Chats.list_intranet_conversation_with_preload()

    socket
    |> assign(:page_title, "New Intranet message")
    |> assign(:intranet_conversations, intranet_conversations)
    |> assign(:intranet_message, %IntranetMessage{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Intranet messages")
    |> assign(:intranet_message, nil)
  end

  @impl true
  def handle_info(
        {IgIntranetWeb.IntranetMessageLive.FormComponent, {:saved, intranet_message}},
        socket
      ) do
    {:noreply, stream_insert(socket, :intranet_messages, intranet_message)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    intranet_message = Chats.get_intranet_message_with_preload!(id)
    {:ok, _} = Chats.delete_intranet_message(intranet_message)

    {:noreply, stream_delete(socket, :intranet_messages, intranet_message)}
  end
end
