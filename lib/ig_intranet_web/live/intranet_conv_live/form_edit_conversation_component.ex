defmodule IgIntranetWeb.IntranetConvLive.FormEditConversationComponent do
  use IgIntranetWeb, :live_component

  alias IgIntranet.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} id="intranet_conversation-form" phx-target={@myself} phx-submit="save">
        <.input field={@form[:conversation_topic]} type="text" label="Conversation topic" />
        <%!-- <.input
          field={@form[:conversation_type]}
          type="select"
          options={Ecto.Enum.values(IgIntranet.Chats.IntranetConversation, :conversation_type)}
          label="Conversation type"
          prompt="Select a conversation type"
        />
        <.input
          field={@form[:conversation_status]}
          type="select"
          options={Ecto.Enum.values(IgIntranet.Chats.IntranetConversation, :conversation_status)}
          label="Conversation status"
          prompt="Select a conversation status"
        /> --%>
        <:actions>
          <.button phx-disable-with="Saving...">Save Intranet conversation</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{current_conversation: current_conversation} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Chats.change_intranet_conversation(current_conversation))
     end)}
  end

  @impl true
  def handle_event("save", %{"intranet_conversation" => current_conversation_params}, socket) do
    save_intranet_conversation(socket, socket.assigns.action, current_conversation_params)
  end

  defp save_intranet_conversation(socket, :edit_conv, current_conversation_params) do
    case Chats.update_intranet_conversation(
           socket.assigns.current_conversation,
           current_conversation_params
         ) do
      {:ok, current_conversation} ->
        notify_parent({:edited, current_conversation})

        {:noreply,
         socket
         |> put_flash(:info, "Intranet conversation updated successfully")
         |> push_patch(to: ~p"/intranet_conv/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
