defmodule IgIntranetWeb.LogsLive do
  use IgIntranetWeb, :live_view

  alias IgIntranet.Chats

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    {:ok, {logs, meta}} =
      Chats.get_log_list(params)

    socket
    |> assign(:page_title, "Logs of operations")
    |> assign(:meta, meta)
    |> stream(:logs, logs)
  end
end
