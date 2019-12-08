defmodule Transmission do
  use ExActor.GenServer

  alias Transmission.Api
  alias Transmission.TorrentAdd
  alias Transmission.TorrentGet
  alias Transmission.TorrentReannounce
  alias Transmission.TorrentRemove
  alias Transmission.TorrentStart
  alias Transmission.TorrentStartNow
  alias Transmission.TorrentStop
  alias Transmission.TorrentVerify

  defstart start_link(url, username, password) do
    initial_state(%{
      tesla: Api.new(url, username, password),
      token: nil
    })
  end

  defcall get_torrents(ids \\ nil), state: state do
    {token, %{torrents: torrents}} =
      Api.execute_method(state.tesla, state.token, TorrentGet.method(ids))

    set_and_reply(%{state | token: token}, torrents)
  end

  defcall stop_torrents(ids \\ nil), state: state do
    {token, %{}} = Api.execute_method(state.tesla, state.token, TorrentStop.method(ids))

    set_and_reply(%{state | token: token}, nil)
  end

  defcall start_torrents(ids \\ nil), state: state do
    {token, %{}} = Api.execute_method(state.tesla, state.token, TorrentStart.method(ids))

    set_and_reply(%{state | token: token}, nil)
  end

  defcall start_now_torrents(ids \\ nil), state: state do
    {token, %{}} = Api.execute_method(state.tesla, state.token, TorrentStartNow.method(ids))

    set_and_reply(%{state | token: token}, nil)
  end

  defcall verify_torrents(ids \\ nil), state: state do
    {token, %{}} = Api.execute_method(state.tesla, state.token, TorrentVerify.method(ids))

    set_and_reply(%{state | token: token}, nil)
  end

  defcall reannounce_torrents(ids \\ nil), state: state do
    {token, %{}} = Api.execute_method(state.tesla, state.token, TorrentReannounce.method(ids))

    set_and_reply(%{state | token: token}, nil)
  end

  defcall add_torrent(options), state: state do
    {token, id} =
      case Api.execute_method(state.tesla, state.token, TorrentAdd.method(options)) do
        {token, %{"torrent-added": %{id: id}}} -> {token, id}
        {token, %{"torrent-duplicate": %{id: id}}} -> {token, id}
      end

    set_and_reply(%{state | token: token}, id)
  end

  defcall remove_torrent(ids, delete_local_data \\ false), state: state do
    {token, %{}} =
      Api.execute_method(state.tesla, state.token, TorrentRemove.method(ids, delete_local_data))

    set_and_reply(%{state | token: token}, nil)
  end
end
