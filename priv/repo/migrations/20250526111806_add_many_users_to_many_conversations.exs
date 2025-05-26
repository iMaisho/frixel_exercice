defmodule IgIntranet.Repo.Migrations.AddManyUsersToManyConversations do
  use Ecto.Migration

  def change do
    create table("conversation_users", primary_key: false) do
      add :user_id, references(:users), null: false
      add :intranet_conversation_id, references(:intranet_conversations), null: false
    end

    create unique_index(:conversation_users, [:user_id, :intranet_conversation_id])
  end
end
