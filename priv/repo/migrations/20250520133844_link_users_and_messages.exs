defmodule IgIntranet.Repo.Migrations.LinkUsersAndMessages do
  use Ecto.Migration

  def change do
    alter table(:intranet_messages) do
      add :user_id, references(:users, on_delete: :nothing)
    end
  end
end
