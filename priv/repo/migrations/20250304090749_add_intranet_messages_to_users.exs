defmodule IgIntranet.Repo.Migrations.AddIntranetMessagesToUsers do
  use Ecto.Migration

  def change do
    alter table(:intranet_messages) do
      add :user_id, references(:users, on_delete: :nothing)
    end

    create index(:intranet_messages, [:user_id])
  end
end
