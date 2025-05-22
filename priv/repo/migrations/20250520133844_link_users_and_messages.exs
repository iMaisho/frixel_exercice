defmodule IgIntranet.Repo.Migrations.LinkUsersAndMessages do
  use Ecto.Migration

  def change do
    alter table(:intranet_messages) do
      add :sender_id, references(:users, on_delete: :nothing), null: false
    end
  end
end
