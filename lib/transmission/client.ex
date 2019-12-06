defmodule Transmission.Client do
  use Tesla

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

  def get_torrents(client) do
    {:ok, token} = auth_token(client)

    {:ok, %Tesla.Env{status: 200, body: %{arguments: %{torrents: torrents}, result: "success"}}} =
      Tesla.post(
        client.tesla,
        "/",
        %{
          method: "torrent-get",
          arguments: %{
            fields: @get_torrents_fields
          }
        },
        headers: [{"X-Transmission-Session-Id", token}, auth_header(client)]
      )

    torrents
  end

  defp auth_token(client) do
    case Tesla.post(client.tesla, "/", %{},
           headers: [{"Content-Type", "application/json"}, auth_header(client)]
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
