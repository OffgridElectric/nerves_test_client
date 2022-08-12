defmodule NervesTestClient.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    config = NervesHubLink.Configurator.build()

    url = Application.fetch_env!(:nerves_test_client, :url)

    config =
      config
      |> Map.put(:socket, Keyword.merge(config.socket, :url, url))
      |> Map.put(:params, Map.merge(config.params, %{
        "tag" => Application.get_env(:nerves_test_client, :tag),
        "serial" => serial(),
        "test_path" => Application.get_env(:nerves_test_client, :test_path)
      }))

    children = [
      {NervesTestClient.Runner, config}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: NervesTestClient.Supervisor)
  end

  defp serial do
    case System.cmd("boardid", []) do
      {out, 0} -> String.trim(out)
      {_, _} -> hostname()
    end
  end

  defp hostname do
    case System.cmd("hostname", []) do
      {out, 0} -> String.trim(out)
      {_, _} -> "dev"
    end
  end
end
