defmodule TransmissionTest do
  use ExUnit.Case
  doctest Transmission

  test "greets the world" do
    assert Transmission.hello() == :world
  end
end
