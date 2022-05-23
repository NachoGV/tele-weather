defmodule TeleWeather.Bot do
  @bot :tele_weather

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command("start")
  command("commands", description: "List all the availible commands")
  command("getcodes", description: "List of region codes")
  command("forecast", description: "Get the daily forecast for the specified region")

  def bot(), do: @bot

  def handle({:command, :start, _msg}, context) do
    answer(context, "Hi! Welcome to TeleWeather!
                    \nUse /commands to see the list of commands")
  end

  def handle({:command, :commands, _msg}, context) do
    answer(context, "Availible commands:
                    \n/getcodes\n List of region codes
                    \n/forecast <region_code>\n Get the daily forecast for the specified region\n Ex: /forecast 28115")
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
        answer(context, "Forecast for:\n#{Map.get(datos, "nombre")}\n\n#{Aux.maps_to_string(Map.get(Map.get(datos, "prediccion"), "dia"))}")
      _other ->
        answer(context, "Invalid code")
    end
  end

  def handle({:command, :alert, alert}, context) do

  end

end
