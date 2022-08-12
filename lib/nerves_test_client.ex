defmodule NervesTestClient do
  @moduledoc false

  @doc false
  def config do
    config = NervesHubLink.Configurator.build()

    url = Application.fetch_env!(:nerves_test_client, :url)

    config
    |> Map.put(:socket, Keyword.merge(config.socket, [url: url]))
    |> Map.put(:params, Map.merge(config.params, %{
      "tag" => Application.get_env(:nerves_test_client, :tag),
      "serial" => serial(),
      "test_path" => Application.get_env(:nerves_test_client, :test_path)
    }))
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
