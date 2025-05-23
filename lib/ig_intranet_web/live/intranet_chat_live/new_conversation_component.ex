defmodule IgIntranetWeb.IntranetChatLive.NewConversationComponent do
  use IgIntranetWeb, :live_component

  alias IgIntranet.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@c_form}
        id="intranet_conversation-form"
        phx-target={@myself}
        phx-submit="save"
        action={~p"/intranet_chat"}
      >
        <.input field={@c_form[:conversation_topic]} type="text" label="Conversation topic" />
        <.input
          field={@c_form[:conversation_type]}
          type="select"
          options={Ecto.Enum.values(IgIntranet.Chats.IntranetConversation, :conversation_type)}
          label="Conversation type"
        />
        <.input
          field={@c_form[:conversation_status]}
          type="select"
          options={Ecto.Enum.values(IgIntranet.Chats.IntranetConversation, :conversation_status)}
          label="Conversation status"
        />

        <.inputs_for :let={message_form} field={@c_form[:intranet_messages]}>
          <.input field={message_form[:message_body]} type="text" label="Message" />
          <.input field={message_form[:sender_id]} type="hidden" value={@sender_id} />
          <.input field={message_form[:recipient_id]} type="hidden" value={@recipient_id} />
        </.inputs_for>

        <:actions>
          <.button phx-disable-with="Saving...">Create and send</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(
        %{intranet_conversation: intranet_conversation} =
          assigns,
        socket
      ) do
    conversation =
      if match?(%Ecto.Association.NotLoaded{}, intranet_conversation.intranet_messages) or
           intranet_conversation.intranet_messages == [] do
        %IgIntranet.Chats.IntranetConversation{
          intranet_conversation
          | intranet_messages: [%IgIntranet.Chats.IntranetMessage{}]
        }
      else
        intranet_conversation
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:c_form, fn ->
       to_form(Chats.change_intranet_conversation(conversation))
     end)}
  end

  @impl true
  def handle_event(
        "save",
        %{
          "intranet_conversation" => intranet_conversation_params
        },
        socket
      ) do
    save_intranet_conversation(socket, socket.assigns.action, intranet_conversation_params)
  end

  defp save_intranet_conversation(socket, :new, intranet_conversation_params) do
    Chats.create_intranet_conversation(intranet_conversation_params)
    |> IO.inspect()
    |> case do
      {:ok, _intranet_conversation} ->
        # notify_parent({:saved, intranet_conversation |> Chats.preload_intranet_messages()})

        {:noreply,
         socket
         |> put_flash(:info, "Intranet conversation created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(form: to_form(changeset))
         |> put_flash(:info, "Intranet conversation created successfully")}
    end
  end
end
