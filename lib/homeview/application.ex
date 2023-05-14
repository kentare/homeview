defmodule Homeview.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      HomeviewWeb.Telemetry,
      # Start the Ecto repository
      Homeview.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Homeview.PubSub},
      # Start Finch
      {Finch, name: Homeview.Finch},
      # Start the Endpoint (http/https)
      HomeviewWeb.Endpoint
      # Start a worker by calling: Homeview.Worker.start_link(arg)
      # {Homeview.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Homeview.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HomeviewWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
