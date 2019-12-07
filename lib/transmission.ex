defmodule Transmission do
  use GenServer

  alias Transmission.Api
  alias Transmission.TorrentAdd
  alias Transmission.TorrentGet
  alias Transmission.TorrentReannounce
  alias Transmission.TorrentStart
  alias Transmission.TorrentStartNow
  alias Transmission.TorrentStop
  alias Transmission.TorrentVerify

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

  def reannounce_torrents(transmission, ids \\ nil) do
    GenServer.call(transmission, {:reannounce_torrents, ids})
  end

  def add_torrent(transmission, options) do
    GenServer.call(transmission, {:add_torrent, options})
  end

  @impl true
  def init({url, username, password}) do
    {:ok,
     %{
       tesla: Api.new(url, username, password),
       token: nil
     }}
  end

  @impl true
  def handle_call({:add_torrent, options}, _from, state) do
    {token, %{arguments: %{"torrent-added": %{id: id}}, result: "success"}} =
      Api.execute_method(state.tesla, state.token, TorrentAdd.method(options))

    {:reply, id, %{state | token: token}}
  end

  @impl true
  def handle_call({:get_torrents, ids}, _from, state) do
    {token, %{arguments: %{torrents: torrents}, result: "success"}} =
      Api.execute_method(state.tesla, state.token, TorrentGet.method(ids))

    {:reply, torrents, %{state | token: token}}
  end

  @impl true
  def handle_call({:stop_torrents, ids}, _from, state) do
    {token, %{result: "success"}} =
      Api.execute_method(state.tesla, state.token, TorrentStop.method(ids))

    {:reply, nil, %{state | token: token}}
  end

  @impl true
  def handle_call({:start_torrents, ids}, _from, state) do
    {token, %{result: "success"}} =
      Api.execute_method(state.tesla, state.token, TorrentStart.method(ids))

    {:reply, nil, %{state | token: token}}
  end

  @impl true
  def handle_call({:start_now_torrents, ids}, _from, state) do
    {token, %{result: "success"}} =
      Api.execute_method(state.tesla, state.token, TorrentStartNow.method(ids))

    {:reply, nil, %{state | token: token}}
  end

  @impl true
  def handle_call({:verify_torrents, ids}, _from, state) do
    {token, %{result: "success"}} =
      Api.execute_method(state.tesla, state.token, TorrentVerify.method(ids))

    {:reply, nil, %{state | token: token}}
  end

  @impl true
  def handle_call({:reannounce_torrents, ids}, _from, state) do
    {token, %{result: "success"}} =
      Api.execute_method(state.tesla, state.token, TorrentReannounce.method(ids))

    {:reply, nil, %{state | token: token}}
  end
end
