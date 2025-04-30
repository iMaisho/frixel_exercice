defmodule IgIntranet.Repo.Migrations.CreateIntranetMessages do
  use Ecto.Migration

  def change do
    create table(:intranet_messages) do
      add :message_body, :text
      add :intranet_conversation_id, references(:intranet_conversations, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:intranet_messages, [:intranet_conversation_id])
  end
end
