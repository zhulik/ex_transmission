defmodule Transmission.TorrentGet do
  alias Transmission.Utils

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
          ids: Utils.cast_ids(ids)
        }
        |> Utils.compact()
    }
  end
end
