defmodule IgIntranetWeb.IntranetChatLive.Show do
  use IgIntranetWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))}  end

  defp page_title(:show), do: "Show Intranet conversation"
  defp page_title(:edit), do: "Edit Intranet conversation"
end
