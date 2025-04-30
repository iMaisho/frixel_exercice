defmodule IgIntranet.Repo do
  use Ecto.Repo,
    otp_app: :ig_intranet,
    adapter: Ecto.Adapters.Postgres
end
