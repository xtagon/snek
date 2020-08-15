defmodule SnekTest do
  use ExUnit.Case
  doctest Snek

  test "greets the world" do
    assert Snek.hello() == :world
  end
end
