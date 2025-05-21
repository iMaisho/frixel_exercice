defmodule IgIntranet.Chats.IntranetMessage do
  @moduledoc """
    Intranet_messages représente les messages de l'intranet.
    Un message fait partie d'une conversation sous la forme: intranet_messages belongs_to intranet_conversation
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Hex.API.User
  alias IgIntranet.Chats.IntranetConversation
  alias IgIntranet.Accounts.User

  @derive {
    Flop.Schema,
    filterable: [:intranet_conversation_id],
    sortable: [
      :inserted_at,
      :message_body
    ],
    adapter_opts: [
      join_fields: [
        conversation_id: [
          binding: :intranet_conversations,
          field: :id,
          ecto_type: :string
        ]
      ]
    ]
  }
  schema "intranet_messages" do
    field :message_body, :string

    belongs_to(:intranet_conversation, IntranetConversation)
    belongs_to(:user, User)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(intranet_message, attrs) do
    intranet_message
    |> cast(attrs, [:message_body, :intranet_conversation_id, :user_id])
    |> validate_required([:message_body, :intranet_conversation_id])
  end
end
