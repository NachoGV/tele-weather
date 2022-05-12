defmodule TeleWeather.Bot do
  @bot :tele_weather

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command("start")
  command("getcodes", description: "List of region codes")
  command("forecast", description: "Get the daily forecast for the specified region")

  def bot(), do: @bot

  def handle({:command, :start, _msg}, context) do
    answer(context, "Hi! Welcome to TeleWeather!
                    \nAvailible commands:
                    \n /getCodes\n List of region codes
                    \n /forecast <region_code>\n Get the daily forecast for the specified region\n Ex: /forecast 28115")
  end

  def handle({:command, :getcodes, _msg}, context) do
    ExGram.send_document(context.update.message.chat.id ,{:file, "RegionCodes.xlsx"}, bot: @bot)
  end

  def handle({:command, :forecast, code}, context) do
    {:ok, response} = TeslaApi.get_muni("api/prediccion/especifica/municipio/diaria/#{code.text}")
    estado = Map.get(response.body, "estado")
    case estado do
      200 ->
        url = Map.get(response.body,"datos")
        answer(context, url)
      _other ->
        answer(context, "Invalid code")
    end
  end

end
