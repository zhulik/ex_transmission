defmodule Transmission.TorrentRemove do
  alias Transmission.Utils

  def method(ids, delete_local_data) do
    %{
      method: "torrent-remove",
      arguments:
        %{
          ids: Utils.cast_ids(ids),
          "delete-local-data": delete_local_data
        }
        |> Utils.compact()
    }
  end
end
