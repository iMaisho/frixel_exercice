defmodule IgIntranet.Repo.Migrations.CreateRecipients do
  use Ecto.Migration

  def change do
    alter table(:intranet_messages) do
      add :recipient_id, references(:users, on_delete: :nothing), null: false
    end
  end
end
