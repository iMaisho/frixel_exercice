defmodule IgIntranetWeb.IntranetConvLive.FormMessageComponent do
  use IgIntranetWeb, :live_component

  alias IgIntranet.Chats.IntranetMessage
  alias IgIntranet.Accounts
  alias IgIntranet.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form_mess} id="intranet_message-form" phx-submit="save">
        <.input field={@form_mess[:message_body]} type="text" placeholder="Send a message here" />
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user_id: user_id, current_conversation_id: current_conversation_id}, socket) do
    intranet_conversations = Chats.list_intranet_conversation_tuple_by_user_id(user_id)

    users = Accounts.list_users_tuple_except_user_id(user_id)

    {:ok,
     socket
     |> assign(intranet_conversations: intranet_conversations)
     |> assign(users: users)
     |> assign(current_conversation_id: current_conversation_id)
     |> assign_form()}
  end

  defp assign_form(socket) do
    form =
      %IntranetMessage{}
      |> Chats.change_intranet_message()
      |> to_form()

    socket
    |> assign(:form_mess, form)
  end
end
