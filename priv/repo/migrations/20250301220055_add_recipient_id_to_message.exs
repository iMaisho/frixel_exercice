defmodule IgIntranet.Repo.Migrations.AddRecipientIdToMessage do
  use Ecto.Migration

  def change do
    alter table(:intranet_messages) do
      add :recipient_id, references(:users, on_delete: :nothing)
    end

    create index(:intranet_messages, [:recipient_id])
  end
end
