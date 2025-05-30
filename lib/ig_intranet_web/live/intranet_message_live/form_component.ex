defmodule IgIntranetWeb.IntranetMessageLive.FormComponent do
  use IgIntranetWeb, :live_component

  alias IgIntranet.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage intranet_message records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="intranet_message-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:intranet_conversation_id]}
          type="select"
          label="Conversation rattachée"
          options={@intranet_conversations}
          prompt="Select a conversation"
        />
        <.input field={@form[:message_body]} type="text" label="Message body" />
        <.input
          field={@form[:user_id]}
          type="text"
          label="Utilisateur rattaché"
          value={(@current_user && @current_user.id) || ""}
        />
        <p>Email utilisateur associé : {(@current_user && @current_user.email) || "N/A"}</p>
        <:actions>
          <.button phx-disable-with="Saving...">Save Intranet message</.button>
        </:actions>
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
  def handle_event("validate", %{"intranet_message" => intranet_message_params}, socket) do
    intranet_message_params =
      maybe_add_user_id_to_params(intranet_message_params, socket.assigns.current_user)

    changeset =
      Chats.change_intranet_message(socket.assigns.intranet_message, intranet_message_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"intranet_message" => intranet_message_params}, socket) do
    intranet_message_params =
      maybe_add_user_id_to_params(intranet_message_params, socket.assigns.current_user)

    save_intranet_message(socket, socket.assigns.action, intranet_message_params)
  end

  defp save_intranet_message(socket, :edit, intranet_message_params) do
    case Chats.update_intranet_message(socket.assigns.intranet_message, intranet_message_params) do
      {:ok, intranet_message} ->
        notify_parent({:saved, intranet_message})

        {:noreply,
         socket
         |> put_flash(:info, "Intranet message updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_intranet_message(socket, :new, intranet_message_params) do
    case Chats.create_intranet_message(intranet_message_params) do
      {:ok, intranet_message} ->
        notify_parent({:saved, intranet_message |> Chats.preload_intranet_conversation()})

        {:noreply,
         socket
         |> put_flash(:info, "Intranet message created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp maybe_add_user_id_to_params(params, current_user) do
    current_user
    |> case do
      nil ->
        params

      _params ->
        params
        |> Map.merge(%{"user_id" => current_user.id})
    end
  end
end
