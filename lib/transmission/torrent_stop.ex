defmodule Transmission.TorrentStop do
  alias Transmission.Utils

  def method(ids) do
    %{
      method: "torrent-stop",
      arguments:
        %{
          ids: Utils.cast_ids(ids)
        }
        |> Utils.compact()
    }
  end
end
