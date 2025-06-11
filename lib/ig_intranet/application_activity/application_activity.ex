defmodule IgIntranet.ApplicationActivity.Log do
  @moduledoc """
  The Activity Log.
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  @derive {
    Flop.Schema,
    filterable: [],
    sortable: [
      :log_event,
      :event_generator,
      :inserted_at
    ],
    default_limit: 10
  }

  schema "application_activity" do
    field :log_event, :string
    field :event_generator, :string

    timestamps(type: :utc_datetime)
  end

  def log_changeset(log, attrs, _opts \\ []) do
    log |> cast(attrs, [:log_event, :event_generator])
  end
end
