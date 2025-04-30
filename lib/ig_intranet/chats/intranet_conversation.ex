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

  schema "intranet_conversations" do
    field :conversation_topic, :string
    field :conversation_type, Ecto.Enum, values: [:public, :private]
    field :conversation_status, Ecto.Enum, values: [:active, :archived]

    has_many(:intranet_messages, IntranetMessage, on_delete: :delete_all)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(intranet_conversation, attrs) do
    intranet_conversation
    |> cast(attrs, [:conversation_topic, :conversation_type, :conversation_status])
    |> validate_required([:conversation_topic, :conversation_type, :conversation_status])
  end
end
