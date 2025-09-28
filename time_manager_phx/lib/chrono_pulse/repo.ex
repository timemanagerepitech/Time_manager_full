defmodule ChronoPulse.Repo do
  use Ecto.Repo,
    otp_app: :chrono_pulse,
    adapter: Ecto.Adapters.Postgres
end
