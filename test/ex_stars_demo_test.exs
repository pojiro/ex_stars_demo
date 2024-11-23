defmodule ExSTARSDemoTest do
  use ExUnit.Case
  doctest ExSTARSDemo

  test "greets the world" do
    assert ExSTARSDemo.hello() == :world
  end
end
