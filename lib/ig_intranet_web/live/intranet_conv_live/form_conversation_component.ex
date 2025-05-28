defmodule IgIntranetWeb.IntranetConvLive.FormConversationComponent do
  use IgIntranetWeb, :live_component

  alias IgIntranet.Chats.IntranetConversation
  alias IgIntranet.Chats.IntranetMessage
  alias IgIntranet.Accounts
  alias IgIntranet.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Nouveau message
      </.header>

      <.simple_form for={@form_conv} id="intranet_conversation-form" phx-submit="save">
        <.input
          field={@form_conv[:conversation_topic]}
          label="Topic"
          type="text"
          placeholder="Titre de votre conversation"
          required
        />
        <.input
          type="select"
          multiple
          label="Recipients"
          required
          options={@other_users_list}
          field={@form_conv[:user_list]}
        />
        <input type="hidden" name="intranet_conversation[conversation_type]" value="private" />
        <input type="hidden" name="intranet_conversation[conversation_status]" value="active" />
        <.inputs_for :let={mess} field={@form_conv[:intranet_messages]}>
          <.input
            field={mess[:message_body]}
            type="text"
            label="Nouveau message"
            placeholder="Démarrez votre conversation"
          />
          <%!-- <.input
            field={mess[:recipient_id]}
            type="select"
            label="Destinataire"
            options={@users}
            prompt="Select a user"
          /> --%>
        </.inputs_for>
        <:actions>
          <.button phx-disable-with="Saving...">Save  message</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user_id: user_id}, socket) do
    users = Accounts.list_users_tuple_except_user_id(user_id)

    {:ok,
     socket
     |> assign(other_users_list: users)
     |> assign_form()}
  end

  defp assign_form(socket) do
    form =
      %IntranetConversation{intranet_messages: [%IntranetMessage{}]}
      |> Chats.change_intranet_conversation()
      |> to_form()

    socket
    |> assign(:form_conv, form)
  end
end
