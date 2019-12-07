defmodule Transmission.TorrentGet do
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

  def command(ids \\ nil) do
    %{
      method: "torrent-get",
      arguments: %{
        fields: @get_torrents_fields,
        ids: ids
      } |> compact()
    }
  end

  defp compact(map) do
    :maps.filter(fn _k, v -> !is_nil(v) end, map)
  end
end
