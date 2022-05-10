defmodule TeleWeather.Bot do
  @bot :tele_weather

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command("start")
  command("help", description: "Print the bot's help")
  command("forecast", description: "Shows forecast of a region")

  middleware(ExGram.Middleware.IgnoreUsername)

  def bot(), do: @bot

  def handle({:command, :start, _msg}, context) do
    answer(context, "Hi!")
  end

  def handle({:command, :help, _msg}, context) do
    answer(context, "Here is your help:")
  end

  def handle({:command, :forecast, _msg}, context) do
    {:ok, response} = TeslaApi.get_muni("api/prediccion/especifica/municipio/diaria/28115")
    answer(context, Map.get(response.body,"datos"))
  end

end
