defmodule DemoVisitsCounter.MixProject do
  use Mix.Project

  def project do
    [
      app: :demo_visits_counter,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DemoVisitsCounter.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:doma_oauth, path: "../doma_oauth"},
      {:plug_cowboy, "~> 2.6"}
    ]
  end
end
