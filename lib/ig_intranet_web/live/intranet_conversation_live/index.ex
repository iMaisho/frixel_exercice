defmodule IgIntranetWeb.IntranetConversationLive.Index do
  use IgIntranetWeb, :live_view
  import Flop.Phoenix
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
    {:ok, {conversations, meta}} = Chats.flop_list_intranet_conversations(params)

    {:noreply,
     socket
     |> assign(conversations: conversations, meta: meta)
     |> apply_action(socket.assigns.live_action, params)}
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

  @impl true
  def handle_event(
        "update-filter",
        params,
        socket
      ) do
    {:noreply, push_patch(socket, to: ~p"/intranet_conversations?#{params}")}
  end

  attr :fields, :list, required: true
  attr :meta, Flop.Meta, required: true
  attr :id, :string, default: nil
  attr :on_change, :string, default: "update-filter"
  attr :target, :string, default: nil

  def filter_form(%{meta: meta} = assigns) do
    assigns = assign(assigns, form: Phoenix.Component.to_form(meta), meta: nil)

    ~H"""
    <.form for={@form} id={@id} phx-target={@target} phx-change={@on_change} phx-submit={@on_change}>
      <.filter_fields :let={i} form={@form} fields={@fields}>
        <.input field={i.field} label={i.label} type={i.type} phx-debounce={120} {i.rest} />
      </.filter_fields>
    </.form>
    """
  end
end
