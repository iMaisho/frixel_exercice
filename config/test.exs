import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# env vars
env_db_user =
  System.get_env("POSTGRES_USR") || "postgres"

env_db_passwd =
  System.get_env("POSTGRES_PASSWD") || "postgres"

env_db_hostname =
  System.get_env("POSTGRES_HOSTNAME") || "localhost"

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ig_intranet, IgIntranet.Repo,
  username: env_db_user,
  password: env_db_passwd,
  hostname: env_db_hostname,
  database: "ig_intranet_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ig_intranet, IgIntranetWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "HsgtLKKhXg5cqVDCcpAjoLLM4xIJ5uoXQ8dje5RcFGrAg9N8qZJCfHU2sRx0uNc0",
  server: false

# In test we don't send emails
config :ig_intranet, IgIntranet.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
