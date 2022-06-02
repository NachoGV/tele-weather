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


  def handle_alerts(chatid, code, op, temp) do
    {:ok, response} = TeslaApi.get_muni("api/prediccion/especifica/municipio/horaria/#{code}")
    IO.inspect(response.body)
    estado = Map.get(response.body, "estado")
    case estado do
      200 ->
        url = Map.get(response.body,"datos")
        {:ok, response} = TeslaApi.get_muni_base(url)
        datos = Map.get(Map.get(List.first(Jason.decode!(Aux.latin1_to_utf8(response.body))), "prediccion"), "dia")
        hora_actual = elem(elem(:calendar.local_time(), 1), 0)
        ExGram.send_message(chatid, "Alerts set for: #{code} #{op} #{temp}", token: "5132964358:AAGqPXBHHWQubRzXB-pOSKM7WAjjBlL4PDY")
        check_temps(chatid, code, op, temp, datos, hora_actual, 6)
      _other ->
        ExGram.send_message(chatid, "Invalid code", token: "5132964358:AAGqPXBHHWQubRzXB-pOSKM7WAjjBlL4PDY")
        exit(-1)
    end
    Process.sleep(3600000)
    handle_alerts(chatid, code, op, temp)
  end

  def check_temps(chatid, code, op, temp, [h|t], hora_actual, contador) do
    if 23 - hora_actual < contador do
      case op do
        "<" ->
          check_temp_under(chatid, temp, Map.get(h,"temperatura"), hora_actual, 23 - hora_actual, Enum.at(String.split(Map.get(h, "fecha"), "T"), 0))
        ">" ->
          check_temp_over(chatid, temp, Map.get(h,"temperatura"), hora_actual, 23 - hora_actual, Enum.at(String.split(Map.get(h, "fecha"), "T"), 0))
      end
      check_temps(chatid, code, op, temp, t, 0, contador-(23-hora_actual))
    else
      case op do
        "<" ->
          check_temp_under(chatid, temp, Map.get(h,"temperatura"), hora_actual, contador, Enum.at(String.split(Map.get(h, "fecha"), "T"), 0))
        ">" ->
          check_temp_over(chatid, temp, Map.get(h,"temperatura"), hora_actual, contador, Enum.at(String.split(Map.get(h, "fecha"), "T"), 0))
      end
    end
  end

  def check_temp_over(_chatid, _temp, _list, _hora_actual, 0, _fecha) do
    nil
  end

  def check_temp_over(chatid, temp, [h|t], hora_actual, contador, fecha) do
    hora = String.to_integer(Map.get(h, "periodo"))
    value = Map.get(h, "value")
    if  hora > hora_actual do
      if value > temp do
        ExGram.send_message(chatid, "Date: #{fecha}\nTime: #{hora}h\nTemperature: #{value}ºC", token: "5132964358:AAGqPXBHHWQubRzXB-pOSKM7WAjjBlL4PDY")
      end
      check_temp_over(chatid, temp, t, hora_actual, contador-1, fecha)
    else
      check_temp_over(chatid, temp, t, hora_actual, contador, fecha)
    end
  end

  def check_temp_under(_chatid, _temp, _list, _hora_actual, 0, _fecha) do
    nil
  end

  def check_temp_under(chatid, temp, [h|t], hora_actual, contador, fecha) do
    hora = String.to_integer(Map.get(h, "periodo"))
    value = Map.get(h, "value")
    if  hora > hora_actual do
      if value < temp do
        ExGram.send_message(chatid, "Date: #{fecha}\nTime: #{hora}h\nTemperature: #{value}ºC", token: "5132964358:AAGqPXBHHWQubRzXB-pOSKM7WAjjBlL4PDY")
      end
      check_temp_under(chatid, temp, t, hora_actual, contador-1, fecha)
    else
      check_temp_under(chatid, temp, t, hora_actual, contador, fecha)
    end
  end

  def alerts_to_string([]) do
    ""
  end

  def alerts_to_string([h|t]) do
    "\nAlert pid: #{elem(h,1)}\nType: #{elem(h,2)}\nCondition: #{elem(h,3)}\n#{alerts_to_string(t)}"
  end

end
