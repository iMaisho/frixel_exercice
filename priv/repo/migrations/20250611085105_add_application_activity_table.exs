defmodule IgIntranet.Repo.Migrations.AddApplicationActivityTable do
  use Ecto.Migration

  def change do
    create table(:application_activity) do
      add :log_event, :string
      add :event_generator, :string

      timestamps(type: :utc_datetime)
    end
  end
end
