defmodule Transmission do
  use GenServer

  @middleware [
    {Tesla.Middleware.JSON, engine: Poison, engine_opts: [keys: :atoms]},
    Tesla.Middleware.Logger,
    {Tesla.Middleware.Timeout, timeout: 30_000}
  ]

  @get_torrents_fields [
    "id",
    "name",
    "status",
    "addedDate",
    "leftUntilDone",
    "sizeWhenDone",
    "eta",
    "uploadRatio",
    "uploadedEver",
    "rateDownload",
    "rateUpload",
    "downloadDir",
    "haveValid",
    "haveUnchecked",
    "isFinished",
    "downloadedEver",
    "percentDone",
    "seedRatioMode",
    "error",
    "errorString",
    "trackers"
  ]

  def start_link(url, username, password) do
    GenServer.start_link(__MODULE__, %{url: url, username: username, password: password})
  end

  @impl true
  def init(%{url: url, username: username, password: password}) do
    middleware =
      [
        {Tesla.Middleware.BaseUrl, url}
      ] ++ @middleware

    {:ok,
     %{
       tesla: Tesla.client(middleware),
       url: url,
       username: username,
       password: password,
       token: nil
     }}
  end

  def get_torrents(transmission) do
    GenServer.call(transmission, :get_torrents)
  end

  @impl true
  def handle_call(:get_torrents, _from, state) do
    state = update_token(state)

    {:ok, %Tesla.Env{status: 200, body: %{arguments: %{torrents: torrents}, result: "success"}}} =
      Tesla.post(
        state.tesla,
        "/",
        %{
          method: "torrent-get",
          arguments: %{
            fields: @get_torrents_fields
          }
        },
        headers: [{"X-Transmission-Session-Id", state.token}, auth_header(state)]
      )

    {:reply, torrents, state}
  end

  defp update_token(state) do
    if state.token == nil do
      {:ok, token} = auth_token(state)
      %{state | token: token}
    else
      state
    end
  end

  defp auth_token(state) do
    case Tesla.post(state.tesla, "/", %{},
           headers: [{"Content-Type", "application/json"}, auth_header(state)]
         ) do
      {:ok, %Tesla.Env{headers: headers, status: 409}} ->
        {:ok, Enum.into(headers, %{})["x-transmission-session-id"]}

      {:ok, %Tesla.Env{status: 401}} ->
        {:error, :invalid_credentials}

      {:error, data} ->
        {:error, data}
    end
  end

  defp auth_header(client) do
    {"Authorization", "Basic #{Base.encode64("#{client.username}:#{client.password}")}"}
  end
end
