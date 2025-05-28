defmodule IgIntranet.Repo.Migrations.DeleteRecipientFromMessage do
  use Ecto.Migration

  def change do
    alter table(:intranet_messages) do
      remove :recipient_id
    end
  end
end
