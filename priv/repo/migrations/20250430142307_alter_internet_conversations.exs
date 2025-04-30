defmodule IgIntranet.Repo.Migrations.AlterInternetConversations do
  use Ecto.Migration

  def change do
    alter table(:intranet_conversations) do
      add :conversation_topic, :string
    end
  end
end
