defmodule IgIntranet.Repo.Migrations.CreateUploadsTable do
  use Ecto.Migration

  def change do
    create table(:uploads) do
      add :name, :string
      add :path, :string
    end
  end
end
