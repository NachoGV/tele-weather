defmodule Aux do

  def get_code(municipio) do
    # Hacer si tenemos tiempo
  end

  def latin1_to_utf8(latin1) do
    latin1
    |> :binary.bin_to_list()
    |> :unicode.characters_to_binary(:latin1)
  end

  def maps_to_string([]) do
    ""
  end

  def maps_to_string([h|t]) do
    "#{Enum.at(String.split(Map.get(h, "fecha"), "T"), 0)}\n#{temp_to_string(Map.get(h, "temperatura"))}\n#{maps_to_string(t)}"
  end

  def temp_to_string([]) do
    ""
  end

  def temp_to_string([h|t]) do
    "#{Map.get(h, "periodo")}h -> #{Map.get(h, "value")}ºC\n#{temp_to_string(t)}"
  end

end
