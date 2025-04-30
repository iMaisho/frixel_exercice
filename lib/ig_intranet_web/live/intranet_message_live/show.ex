defmodule IgIntranetWeb.IntranetMessageLive.Show do
  use IgIntranetWeb, :live_view

  alias IgIntranet.Chats

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    intranet_conversations = Chats.list_intranet_conversation_with_preload()

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:intranet_conversations, intranet_conversations)
     |> assign(:intranet_message, Chats.get_intranet_message_with_preload!(id))}
  end

  defp page_title(:show), do: "Show Intranet message"
  defp page_title(:edit), do: "Edit Intranet message"
end
