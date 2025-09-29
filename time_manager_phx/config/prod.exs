# config/dev.exs and config/prod.exs

import Config

config :chrono_pulse, ChronoPulse.Repo,
  username: System.get_env("PGUSER") || "postgres",
  password: System.get_env("PGPASSWORD") || "postgres",
  hostname: System.get_env("PGHOST") || "chrono_postgres",
  database: System.get_env("PGDATABASE") || "chrono_pulse_dev",
  port: String.to_integer(System.get_env("PGPORT") || "5432"),
  pool_size: 10,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

# Phoenix Endpoint
config :chrono_pulse, ChronoPulseWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "something-very-long-and-random",
  server: true,
  code_reloader: false,
  check_origin: false
