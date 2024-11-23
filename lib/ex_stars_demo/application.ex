defmodule ExSTARSDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        # Children for all targets
        # Starts a worker by calling: ExSTARSDemo.Worker.start_link(arg)
        # {ExSTARSDemo.Worker, arg},
        {ExSTARSDemo, [stars_client_name: "term1", stars_client_key: "stars"]}
      ] ++ children(Nerves.Runtime.mix_target())

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExSTARSDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  defp children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: ExSTARSDemo.Worker.start_link(arg)
      # {ExSTARSDemo.Worker, arg},
    ]
  end

  defp children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: ExSTARSDemo.Worker.start_link(arg)
      # {ExSTARSDemo.Worker, arg},
    ]
  end
end
