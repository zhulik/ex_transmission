defmodule Transmission do
  use GenServer

  alias Tesla.Middleware
  alias Transmission.TorrentGet
  alias Transmission.TorrentStart
  alias Transmission.TorrentStartNow
  alias Transmission.TorrentStop
  alias Transmission.TorrentVerify

  @middlewares [
    {Middleware.JSON, engine: Poison, engine_opts: [keys: :atoms]},
    Middleware.Logger,
    {Middleware.Timeout, timeout: 30_000}
  ]

  def start_link(url, username, password) do
    GenServer.start_link(__MODULE__, {url, username, password})
  end

  def get_torrents(transmission, ids \\ nil) do
    GenServer.call(transmission, {:get_torrents, ids})
  end

  def stop_torrents(transmission, ids \\ nil) do
    GenServer.call(transmission, {:stop_torrents, ids})
  end

  def start_torrents(transmission, ids \\ nil) do
    GenServer.call(transmission, {:start_torrents, ids})
  end

  def start_now_torrents(transmission, ids \\ nil) do
    GenServer.call(transmission, {:start_now_torrents, ids})
  end

  def verify_torrents(transmission, ids \\ nil) do
    GenServer.call(transmission, {:verify_torrents, ids})
  end

  @impl true
  def init({url, username, password}) do
    middleware =
      [
        {Middleware.BaseUrl, url},
        {Middleware.BasicAuth, %{username: username, password: password}}
      ] ++ @middlewares

    {:ok,
     %{
       tesla: Tesla.client(middleware),
       token: nil
     }}
  end

  @impl true
  def handle_call({:get_torrents, ids}, _from, state) do
    {token, %{arguments: %{torrents: torrents}, result: "success"}} =
      execute_method(state.tesla, state.token, TorrentGet.method(ids))

    {:reply, torrents, %{state | token: token}}
  end

  @impl true
  def handle_call({:stop_torrents, ids}, _from, state) do
    {token, %{result: "success"}} =
      execute_method(state.tesla, state.token, TorrentStop.method(ids))

    {:reply, nil, %{state | token: token}}
  end

  @impl true
  def handle_call({:start_torrents, ids}, _from, state) do
    {token, %{result: "success"}} =
      execute_method(state.tesla, state.token, TorrentStart.method(ids))

    {:reply, nil, %{state | token: token}}
  end

  @impl true
  def handle_call({:start_now_torrents, ids}, _from, state) do
    {token, %{result: "success"}} =
      execute_method(state.tesla, state.token, TorrentStartNow.method(ids))

    {:reply, nil, %{state | token: token}}
  end

  @impl true
  def handle_call({:verify_torrents, ids}, _from, state) do
    {token, %{result: "success"}} =
      execute_method(state.tesla, state.token, TorrentVerify.method(ids))

    {:reply, nil, %{state | token: token}}
  end

  defp execute_method(tesla, token, method) do
    case Tesla.post(
           tesla,
           "/",
           method,
           headers: [{"X-Transmission-Session-Id", token || ""}]
         ) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {token, body}

      {:ok, %Tesla.Env{status: 409}} ->
        {:ok, token} = auth_token(tesla)
        execute_method(tesla, token, method)
    end
  end

  defp auth_token(tesla) do
    case Tesla.post(tesla, "/", %{}, headers: [{"Content-Type", "application/json"}]) do
      {:ok, %Tesla.Env{headers: headers, status: 409}} ->
        {:ok, Enum.into(headers, %{})["x-transmission-session-id"]}

      {:ok, %Tesla.Env{status: 401}} ->
        {:error, :invalid_credentials}

      {:error, data} ->
        {:error, data}
    end
  end
end
