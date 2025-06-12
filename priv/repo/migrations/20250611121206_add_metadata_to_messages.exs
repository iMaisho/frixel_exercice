defmodule IgIntranet.Repo.Migrations.AddMetadataToMessages do
  use Ecto.Migration

  def change do
    alter table("intranet_messages") do
      add :meta_data, :jsonb
    end
  end
end
