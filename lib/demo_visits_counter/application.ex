defmodule DemoVisitsCounter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: DemoVisitsCounter.Registry},
      {DynamicSupervisor, strategy: :one_for_one, name: DemoVisitsCounter.DynamicSupervisor},
      {Plug.Cowboy,
       scheme: :http,
       plug: DemoVisitsCounter.Router,
       options: [
         otp_app: :demo_visits_counter,
         port: 4001
       ]}
    ]

    opts = [strategy: :one_for_one, name: DemoVisitsCounter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
