defmodule TeleWeather.Bot do
  @bot :tele_weather

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command("start")
  command("commands", description: "List all the availible commands")
  command("getcodes", description: "List of region codes")
  command("forecast", description: "Get the daily forecast for the specified region for the next 48h")
  command("week_forecast", description: "Get temperatures for the next 6 days")
  command("weather_alert", description: "Sets a weather alert")
  command("my_alerts", description: "List all the set alerts")
  command("delete_alert", decription: "Delete the specified alert")

  def bot(), do: @bot

  def handle({:command, :start, _msg}, context) do
    answer(context, "Hi! Welcome to TeleWeather!
                    \nUse /commands to see the list of commands")
  end

  def handle({:command, :commands, _msg}, context) do
    answer(context, "Availible commands:
                    \n/getcodes\n File containing the list of region codes availible
                    \n/forecast [region_code]\n Get the daily forecast for the specified region\n Ex: /forecast 28115
                    \n/week_forecast [region_code]\n Get the week forecast for the specified region\n Ex: /week_forecast 28115
                    \n/weather_alert [region_code] [<,>] [degrees]\n Sets an weather alert for checking if temperatures go over/down XºC\n Ex: /weather_alert 28115 > 30\n /weather_alert 28115 < 10
                    \n/my_alerts\n List all user's set alerts
                    \n/delete_alert [alert_id]\n Deletes the specifies alert")
  end

  def handle({:command, :getcodes, _msg}, context) do
    ExGram.send_document(context.update.message.chat.id ,{:file, "RegionCodes.xlsx"}, bot: @bot)
  end

  def handle({:command, :forecast, code}, context) do
    {:ok, response} = TeslaApi.get_muni("api/prediccion/especifica/municipio/horaria/#{code.text}")
    estado = Map.get(response.body, "estado")
    case estado do
      200 ->
        url = Map.get(response.body,"datos")
        {:ok, response} = TeslaApi.get_muni_base(url)
        datos = List.first(Jason.decode!(Aux.latin1_to_utf8(response.body)))
        answer(context, "Forecast for:\n#{Map.get(datos, "nombre")}\n\n#{Aux.maps_to_string_forecast(Map.get(Map.get(datos, "prediccion"), "dia"))}")
      _other ->
        answer(context, "Invalid code")
    end
  end

  def handle({:command, :week_forecast, code}, context) do
    {:ok, response} = TeslaApi.get_muni("api/prediccion/especifica/municipio/diaria/#{code.text}")
    estado = Map.get(response.body, "estado")
    case estado do
      200 ->
        url = Map.get(response.body,"datos")
        {:ok, response} = TeslaApi.get_muni_base(url)
        datos = List.first(Jason.decode!(Aux.latin1_to_utf8(response.body)))
        answer(context, "Forecast for:\n#{Map.get(datos, "nombre")}\n\n#{Aux.maps_to_string_week_forecast(Map.get(Map.get(datos, "prediccion"), "dia"))}")
      _other ->
        answer(context, "Invalid code")
    end
  end

  def handle({:command, :weather_alert, alert}, context) do
    code = Enum.at(String.split(alert.text, " "), 0)
    op = Enum.at(String.split(alert.text, " "), 1)
    temp = Enum.at(String.split(alert.text, " "), 2)
    chatid = context.update.message.chat.id
    pid = spawn(fn -> Aux.handle_alerts(chatid, code, op, temp) end)

    IO.inspect(pid)
    # añadir a ETS alertas => {pid, chatid, :weather_alert, op, temp}

    case op do
      "<" -> answer(context, "Alarm set for temperatures under #{temp}")
      ">" -> answer(context, "Alarm set for temperatures over #{temp}")
    end

  end

  def handle({:command, :my_alerts, _msg}, context) do
    answer(context, "To be implemented ;)")
  end

  def handle({:command, :delete_alert, _alert_id}, context) do
    answer(context, "To be implemented ;)")
  end

end
