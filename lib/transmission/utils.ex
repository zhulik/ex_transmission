defmodule Transmission.Utils do
  def cast_ids(ids) when is_nil(ids) or is_list(ids) do
    ids
  end

  def cast_ids(ids) do
    [ids]
  end

  def compact(map) do
    :maps.filter(fn _k, v -> !is_nil(v) end, map)
  end
end
