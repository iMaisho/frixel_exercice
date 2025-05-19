defmodule IgIntranet.Chats.IntranetConversation do
  @moduledoc """
    Intranet_conversations représente les conversations de l'intranet.
    Une conversation a plusieurs types, publique ou privée.
    Une conversation a plusieurs statuts, actives ou archivées.
    Une conversation contient plusieurs messages, ils sont rattachés par la relation suivante: intranet_conversation has_many intranet_messages.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias IgIntranet.Chats.IntranetMessage

  @derive {
    Flop.Schema,
    filterable: [
      :conversation_type,
      :conversation_status,
      :conversation_topic,
      :inserted_at,
      :updated_at,
      :message_body
    ],
    sortable: [
      :conversation_type,
      :conversation_status,
      :conversation_topic,
      :inserted_at,
      :updated_at,
      :message_body
    ],
    adapter_opts: [
      join_fields: [
        message_body: [
          binding: :intranet_messages,
          field: :message_body,
          ecto_type: :string
        ]
      ]
    ],
    default_limit: 10
  }

  schema "intranet_conversations" do
    field :conversation_type, Ecto.Enum, values: [:public, :private]
    field :conversation_status, Ecto.Enum, values: [:active, :archived]
    field :conversation_topic, :string

    has_many(:intranet_messages, IntranetMessage, on_delete: :delete_all)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(intranet_conversation, attrs) do
    intranet_conversation
    |> cast(attrs, [:conversation_type, :conversation_status, :conversation_topic])
    |> validate_required([:conversation_type, :conversation_status, :conversation_topic])
    |> unique_constraint(:conversation_topic)
  end
end
