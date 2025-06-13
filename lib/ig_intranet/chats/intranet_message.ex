defmodule IgIntranet.Chats.IntranetMessage do
  @moduledoc """
    Intranet_messages représente les messages de l'intranet.
    Un message fait partie d'une conversation sous la forme: intranet_messages belongs_to intranet_conversation
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias IgIntranet.Chats.{IntranetConversation, MessageMetadata}
  alias IgIntranet.Accounts.User

  schema "intranet_messages" do
    field :message_body, :string

    embeds_one :meta_data, MessageMetadata, on_replace: :update

    belongs_to(:intranet_conversation, IntranetConversation)
    belongs_to(:user, User)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(intranet_message, attrs) do
    intranet_message
    |> cast(attrs, [:message_body, :intranet_conversation_id, :user_id])
    |> cast_embed(:meta_data)
    |> validate_required([:message_body, :intranet_conversation_id])
  end

  @doc """
  Changeset ne rendant pas obligatoire :intranet_conversation_id en paramètre.
  Utilisé par &IntranetConversation.changeset/2 au travers du &cast_assoc/3,
  lui-même utilisé par IntranetChatLive dans le formulaire avec l'inputs_for : lorssque l'on crée une conversation et son premier message en même temps.

  """
  def nested_changeset(intranet_message, attrs) do
    intranet_message
    |> cast(attrs, [:message_body, :intranet_conversation_id, :user_id])
    |> cast_embed(:meta_data, with: &IgIntranet.Chats.MessageMetadata.changeset/2)
    |> validate_required([:message_body])
  end
end

defmodule IgIntranet.Chats.MessageMetadata do
  use Ecto.Schema
  import Ecto.Changeset
  alias IgIntranet.Chats.MessageReaction

  @primary_key false
  schema "meta_data" do
    field :url_meta, {:array, :string}
    field :mentions_meta, {:array, :string}
    embeds_many :reactions, MessageReaction
    embeds_many :uploads, Upload
  end

  def changeset(metadata, attrs) do
    metadata
    |> cast(attrs, [:url_meta, :mentions_meta])
    |> cast_embed(:reactions)
    |> cast_embed(:uploads)
  end
end

defmodule IgIntranet.Chats.MessageReaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :emoji, :string
    field :user_id, :integer
  end

  @allowed_emojis ["❤️", "😂", "😍", "😭", "🤯", "💩"]

  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:emoji, :user_id])
    |> validate_required([:emoji, :user_id])
    |> validate_inclusion(:emoji, @allowed_emojis)
  end
end

defmodule IgIntranet.Chats.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :name, :string
    field :path, :string
  end

  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:name, :path])
    |> validate_required([])
  end
end
