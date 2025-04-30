defmodule IgIntranetWeb.IntranetConversationLive.Show do
  use IgIntranetWeb, :live_view

  alias IgIntranet.Chats

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:intranet_conversation, Chats.get_intranet_conversation_with_preload!(id))}
  end

  defp page_title(:show), do: "Show Intranet conversation"
  defp page_title(:edit), do: "Edit Intranet conversation"
end
