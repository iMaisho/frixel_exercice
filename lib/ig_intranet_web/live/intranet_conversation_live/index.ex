defmodule IgIntranetWeb.IntranetConversationLive.Index do
  use IgIntranetWeb, :live_view

  alias IgIntranet.Chats
  alias IgIntranet.Chats.IntranetConversation

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:form, to_form(%{"filter" => ""}, as: :filter_form))
     |> assign(:intranet_conversation_list, Chats.list_intranet_conversation_with_preload())
     |> stream(:intranet_conversations, Chats.list_intranet_conversation_with_preload())}
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

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Intranet conversations")
    |> assign(:intranet_conversation, nil)
  end

  @impl true
  def handle_info(
        {IgIntranetWeb.IntranetConversationLive.FormComponent, {:saved, intranet_conversation}},
        socket
      ) do
    {:noreply, stream_insert(socket, :intranet_conversations, intranet_conversation)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    intranet_conversation = Chats.get_intranet_conversation!(id)
    {:ok, _} = Chats.delete_intranet_conversation(intranet_conversation)

    {:noreply, stream_delete(socket, :intranet_conversations, intranet_conversation)}
  end

  def handle_event("validate", %{"filter_form" => %{"filter" => value}}, socket) do
    filtered = Chats.list_intranet_conversations_filtered(value)
    # socket.assigns.intranet_conversation_list
    # |> Enum.filter(fn conv ->
    #   String.contains?(String.downcase(conv.conversation_topic), String.downcase(value))
    # end)

    {:noreply,
     socket
     |> assign(:form, to_form(%{"filter" => value}, as: :filter_form))
     |> stream(:intranet_conversations, filtered, reset: true)}
  end
end
