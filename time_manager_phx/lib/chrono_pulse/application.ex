defmodule ChronoPulse.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Telemetry supervisor
      ChronoPulseWeb.Telemetry,
      # Database repo
      ChronoPulse.Repo,
      # PubSub system
      {Phoenix.PubSub, name: ChronoPulse.PubSub},
      # Start to serve requests (must be last)
      ChronoPulseWeb.Endpoint
      # Add workers here if needed, e.g. {ChronoPulse.Worker, arg}
    ]

    opts = [strategy: :one_for_one, name: ChronoPulse.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ChronoPulseWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
