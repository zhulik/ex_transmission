defmodule Transmission.TorrentVerify do
  alias Transmission.Utils

  def method(ids) do
    %{
      method: "torrent-verify",
      arguments:
        %{
          ids: Utils.cast_ids(ids)
        }
        |> Utils.compact()
    }
  end
end
