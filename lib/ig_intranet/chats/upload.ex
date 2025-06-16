defmodule IgIntranet.Chats.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "uploads" do
    field :name, :string
    field :path, :string
  end

  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:name, :path])
    |> validate_required([])
  end
end
