defmodule NervesTestClient.Runner do
  use Slipstream
  require Logger

  @rejoin_after 5_000

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @impl Slipstream
  def init(config) do
    opts = [
      # mint_opts: [protocols: [:http1], transport_opts: config.ssl],
      uri: config.socket[:url],
      rejoin_after_msec: [@rejoin_after],
      reconnect_after_msec: config.socket[:reconnect_after_msec]
    ]

    socket =
      new_socket()
      |> assign(
        params: config.params,
        topic: "device:" <> config.params["serial"]
      )
      |> connect!(opts)

    {:ok, socket}
  end

  @impl Slipstream
  def handle_connect(%{assigns: %{params: params, topic: topic}} = socket) do
    socket =
      socket
      |> join(topic, %{
        system: params["nerves_fw_platform"],
        status: "ready"
      })

    {:ok, socket}
  end

  @impl Slipstream
  def handle_join("device:" <> _ = topic, _reply, %{assigns: %{topic: topic}} = socket) do
    Logger.info("Joined #{inspect topic}")
    push!(socket, topic, "test_begin", [])
    test_pid = spawn_test(socket.assigns.params["test_path"])
    socket = assign(socket, :test_pid, test_pid)

    {:ok, socket}
  end

  @impl Slipstream
  def handle_info(
        {:test_result, test_pid, {:error, reason}},
        %{assigns: %{test_pid: test_pid}} = socket
      ) do
    Logger.error("Error running tests: #{inspect(reason)}")
    {:ok, socket}
  end

  def handle_info(
        {:test_result, test_pid, {:ok, {test_io, test_result}}},
        %{assigns: %{topic: topic, test_pid: test_pid}} = socket
      ) do
    Logger.info("Received test results")
    push!(socket, topic, "test_result", %{
      "test_results" => test_result,
      "test_io" => test_io
    })

    {:ok, socket}
  end

  @impl Slipstream
  def handle_topic_close(topic, reason, %{assigns: %{topic: topic}} = socket) do
    Logger.error("topic closed: #{inspect reason}")
    rejoin(socket, topic)
  end

  ###
  ### Priv
  ###
  defp spawn_test(path) do
    caller = self()

    spawn_link(fn ->
      ret = ExUnitRelease.run(path: path)
      send(caller, {:test_result, self(), ret})
    end)
  end
end
