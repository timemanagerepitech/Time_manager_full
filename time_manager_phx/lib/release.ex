defmodule ChronoPulse.Release do
  @moduledoc false
  @app :chrono_pulse

  def migrate do
    IO.puts(">>> Running Ecto migrations...")
    Application.load(@app)

    for repo <- Application.fetch_env!(@app, :ecto_repos) do
      Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end
end
