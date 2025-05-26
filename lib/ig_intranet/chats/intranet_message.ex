defmodule IgIntranet.Chats.IntranetMessage do
  @moduledoc """
    Intranet_messages représente les messages de l'intranet.
    Un message fait partie d'une conversation sous la forme: intranet_messages belongs_to intranet_conversation
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias IgIntranet.Chats.IntranetConversation
  alias IgIntranet.Accounts.User

  schema "intranet_messages" do
    field :message_body, :string

    belongs_to(:intranet_conversation, IntranetConversation)
    belongs_to(:user, User)
    belongs_to(:recipient, User, foreign_key: :recipient_id)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(intranet_message, attrs) do
    intranet_message
    |> cast(attrs, [:message_body, :intranet_conversation_id, :user_id, :recipient_id])
    |> validate_required([:message_body, :intranet_conversation_id])
  end

  @doc """
  Changeset ne rendant pas obligatoire :intranet_conversation_id en paramètre.
  Utilisé par &IntranetConversation.changeset/2 au travers du &cast_assoc/3,
  lui-même utilisé par IntranetChatLive dans le formulaire avec l'inputs_for : lorssque l'on crée une conversation et son premier message en même temps.

  """
  def nested_changeset(intranet_message, attrs) do
    intranet_message
    |> cast(attrs, [:message_body, :intranet_conversation_id, :user_id, :recipient_id])
    |> validate_required([:message_body])
  end
end
