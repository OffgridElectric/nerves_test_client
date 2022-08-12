defmodule NervesTestClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :nerves_test_client,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {NervesTestClient.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_unit_release, "~> 0.1"},
      {:phoenix_client, "~> 0.7"},
      {:websocket_client, "~> 1.3"},
      {:jason, "~> 1.0"},
      {:nerves_hub_link, "~> 0.11"},
      {:vintage_net, "~> 0.12"}
    ]
  end
end
