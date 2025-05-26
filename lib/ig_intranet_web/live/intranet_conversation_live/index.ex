defmodule IgIntranetWeb.IntranetConversationLive.Index do
  use IgIntranetWeb, :live_view

  alias IgIntranet.Chats
  alias IgIntranet.Chats.IntranetConversation

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Intranet conversation")
    |> assign(:intranet_conversation, Chats.get_intranet_conversation_with_preload!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Intranet conversation")
    |> assign(:intranet_conversation, %IntranetConversation{})
  end

  defp apply_action(socket, :index, params) do
    {:ok, {intranet_conversations, meta}} =
      Chats.list_pets(params)

    socket
    |> assign(:page_title, "Listing Intranet conversations")
    |> assign(:intranet_conversation, nil)
    |> assign(:meta, meta)
    |> stream(:intranet_conversations, intranet_conversations, reset: true)
  end

  @impl true
  def handle_info(
        {IgIntranetWeb.IntranetConversationLive.FormComponent, {:saved, intranet_conversation}},
        socket
      ) do
    {
      :noreply,
      stream_insert(socket, :intranet_conversations, intranet_conversation, at: 0)
    }
  end

  @impl true
  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    {:noreply, push_patch(socket, to: ~p"/intranet_conversations?#{params}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    intranet_conversation = Chats.get_intranet_conversation!(id)
    {:ok, _} = Chats.delete_intranet_conversation(intranet_conversation)

    {:noreply, stream_delete(socket, :intranet_conversations, intranet_conversation)}
  end
end
