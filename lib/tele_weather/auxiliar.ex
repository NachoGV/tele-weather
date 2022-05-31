defmodule Aux do

  def get_code(municipio) do
    codes =
      %{
      }
    Map.get(codes, municipio)
  end

  def latin1_to_utf8(latin1) do
    latin1
    |> :binary.bin_to_list()
    |> :unicode.characters_to_binary(:latin1)
  end

  def maps_to_string_forecast([]) do
    ""
  end

  def maps_to_string_forecast([h|t]) do
    "#{Enum.at(String.split(Map.get(h, "fecha"), "T"), 0)}\n#{temp_to_string_forecast(Map.get(h, "temperatura"))}\n#{maps_to_string_forecast(t)}"
  end

  def temp_to_string_forecast([]) do
    ""
  end

  def temp_to_string_forecast([h|t]) do
    "#{Map.get(h, "periodo")}h -> #{Map.get(h, "value")}ºC\n#{temp_to_string_forecast(t)}"
  end

  def maps_to_string_week_forecast([]) do
    ""
  end

  def maps_to_string_week_forecast([h|t]) do
    IO.inspect(t)
    "#{Enum.at(String.split(Map.get(h, "fecha"), "T"), 0)}\nMáxima -> #{Map.get(Map.get(h, "temperatura"), "maxima")}ºC\nMínima -> #{Map.get(Map.get(h, "temperatura"), "minima")}ºC\n\n#{maps_to_string_week_forecast(t)}"
  end

  def handle_alerts(code, chatid, op, temp) do

  end

end
