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
    default_limit: 4
  }

  schema "intranet_conversations" do
    field :conversation_type, Ecto.Enum, values: [:public, :private]
    field :conversation_status, Ecto.Enum, values: [:active, :archived]
    field :conversation_topic, :string
    field :user_list, {:array, :string}, virtual: true

    has_many(:intranet_messages, IntranetMessage, on_delete: :delete_all)

    many_to_many(:users, IgIntranet.Accounts.User,
      join_through: "conversation_users",
      on_replace: :delete
    )

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(intranet_conversation, attrs) do
    intranet_conversation
    |> cast(attrs, [:conversation_type, :conversation_status, :conversation_topic, :user_list])
    |> cast_assoc(:intranet_messages,
      with: &IgIntranet.Chats.IntranetMessage.nested_changeset/2,
      required: true
    )
    |> validate_required([:conversation_type, :conversation_status, :conversation_topic])
    |> unique_constraint(:conversation_topic)
  end

  def changeset_with_users(intranet_conversation, current_user, attrs) do
    user_list =
      case attrs["user_list"] do
        nil -> []
        ids -> [current_user | IgIntranet.Accounts.list_users_by_id(ids)]
      end

    intranet_conversation
    |> changeset(attrs)
    |> put_assoc(:users, user_list)
    |> validate_users_present(user_list)
  end

  defp validate_users_present(changeset, []),
    do: add_error(changeset, :users, "must not be empty")

  defp validate_users_present(changeset, _), do: changeset
end
