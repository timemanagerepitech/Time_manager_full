import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :chrono_pulse, ChronoPulse.Repo,
  username: System.get_env("PGUSER") || "postgres",
  password: System.get_env("PGPASSWORD") || "postgres",
  hostname: System.get_env("PGHOST") || "localhost",
  port: String.to_integer(System.get_env("PGPORT") || "5432"),
  database: (System.get_env("PGDATABASE") || "chrono_pulse_test") <> (System.get_env("MIX_TEST_PARTITION") || ""),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online()

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chrono_pulse, ChronoPulseWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "E43saqRlPND6iRVgZr7F5c0Y/5H6HRUKXJVL2F5arqcm+kGfW1XmUAmawHOL+pa8",
  server: false

# In test we don't send emails
config :chrono_pulse, ChronoPulse.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
