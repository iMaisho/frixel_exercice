defmodule IgIntranet.Chats.IntranetMessage do
  @moduledoc """
    Intranet_messages représente les messages de l'intranet.
    Un message fait partie d'une conversation sous la forme: intranet_messages belongs_to intranet_conversation
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias IgIntranet.Chats.IntranetConversation

  schema "intranet_messages" do
    field :message_body, :string

    belongs_to(:intranet_conversation, IntranetConversation)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(intranet_message, attrs) do
    intranet_message
    |> cast(attrs, [:message_body, :intranet_conversation_id])
    |> validate_required([:message_body, :intranet_conversation_id])
  end
end
