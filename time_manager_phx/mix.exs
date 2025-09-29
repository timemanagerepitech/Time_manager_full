defmodule ChronoPulse.MixProject do
  use Mix.Project

  def project do
    [
      app: :chrono_pulse,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # OTP application configuration
  def application do
    [
      mod: {ChronoPulse.Application, []},
      extra_applications: [:logger, :runtime_tools, :swoosh, :hackney]
    ]
  end

  # Paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Project dependencies
  defp deps do
    [
      {:phoenix, "~> 1.8.1"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:swoosh, "~> 1.16"},        # For email, requires hackney
      {:hackney, "~> 1.19"},       # HTTP client used by Swoosh and Tesla
      {:tesla, "~> 1.7"},          # HTTP client for OpenAI
      {:jason, "~> 1.4"},          # JSON parser
      {:req, "~> 0.5"},            # Optional HTTP client
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:bandit, "~> 1.5"}          # HTTP server for Phoenix in prod
    ]
  end

  # Aliases for setup, reset, and test
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      precommit: ["compile --warning-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end
end
