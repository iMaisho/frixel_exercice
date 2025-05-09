defmodule IgIntranet.Repo.Migrations.AddConversationTopic do
  use Ecto.Migration

  def change do
    alter table(:intranet_conversations) do
      add :conversation_topic, :string
    end

    create unique_index(:intranet_conversations, [:conversation_topic])
  end
end
