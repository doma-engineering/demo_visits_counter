defmodule DemoVisitsCounterTest do
  use ExUnit.Case
  doctest DemoVisitsCounter

  test "greets the world" do
    assert DemoVisitsCounter.hello() == :world
  end
end
