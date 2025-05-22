defmodule IgIntranetWeb.IntranetChatLive.FormComponent do
  use IgIntranetWeb, :live_component

  alias IgIntranet.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="intranet_message-form"
        phx-target={@myself}
        phx-submit="save"
      >
        <.input field={@form[:message_body]} type="text" placeholder="Send a message here" />

        <.input
          field={@form[:intranet_conversation_id]}
          type="hidden"
          value={@current_conversation_id}
        />

        <.input field={@form[:sender_id]} type="hidden" value={@sender_id} />
        <.input field={@form[:recipient_id]} type="hidden" value={@recipient_id} />
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{intranet_message: intranet_message} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Chats.change_intranet_message(intranet_message))
     end)}
  end

  @impl true

  def handle_event("save", %{"intranet_message" => intranet_message_params}, socket) do
    save_intranet_message(socket, socket.assigns.action, intranet_message_params)
  end

  defp save_intranet_message(socket, :new, intranet_message_params) do
    case Chats.create_intranet_message(intranet_message_params) do
      {:ok, _intranet_message} ->
        {:noreply,
         socket
         |> put_flash(:info, "Message sent")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
