defmodule FullNewsfeed.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      FullNewsfeedWeb.Telemetry,
      # Start the Ecto repository
      FullNewsfeed.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: FullNewsfeed.PubSub},
      # Start Finch
      {Finch, name: FullNewsfeed.Finch},
      # Start the Endpoint (http/https)
      FullNewsfeedWeb.Endpoint,
      Supervisor.child_spec({FullNewsfeed.Servers.MessageServer,  [:message_server, []]}, id: :message_server),
      Supervisor.child_spec({FullNewsfeed.Servers.Scheduler,  [:scheduler, []]}, id: :scheduler)
      # FullNewsfeed.ThinWrapper,
      # {Task.Supervisor, name: FullNewsfeed.TaskSupervisor}

      # Start a worker by calling: FullNewsfeed.Worker.start_link(arg)
      # {FullNewsfeed.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FullNewsfeed.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FullNewsfeedWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
