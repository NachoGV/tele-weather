defmodule TeleWeatherTest do
  use ExUnit.Case
  doctest TeleWeather

  test "greets the world" do
    assert TeleWeather.hello() == :world
  end
end
