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

  def method(ids \\ nil) do
    %{
      method: "torrent-get",
      arguments:
        %{
          fields: @get_torrents_fields,
          ids: cast_ids(ids)
        }
        |> compact()
    }
  end

  defp cast_ids(ids) when is_nil(ids) or is_list(ids) do
    ids
  end

  defp cast_ids(ids) do
    [ids]
  end

  defp compact(map) do
    :maps.filter(fn _k, v -> !is_nil(v) end, map)
  end
end
