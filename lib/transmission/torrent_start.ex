defmodule Transmission.TorrentStart do
  alias Transmission.Utils

  def method(ids) do
    %{
      method: "torrent-start",
      arguments:
        %{
          ids: Utils.cast_ids(ids)
        }
        |> Utils.compact()
    }
  end
end
