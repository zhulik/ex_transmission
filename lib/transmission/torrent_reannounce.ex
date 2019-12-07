defmodule Transmission.TorrentReannounce do
  alias Transmission.Utils

  def method(ids) do
    %{
      method: "torrent-reannounce",
      arguments:
        %{
          ids: Utils.cast_ids(ids)
        }
        |> Utils.compact()
    }
  end
end
