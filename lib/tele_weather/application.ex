defmodule TeleWeather.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: TeleWeather.Worker.start_link(arg)
      # {TeleWeather.Worker, arg}
      ExGram,
      {TeleWeather.Bot, [method: :polling, token: "5132964358:AAGqPXBHHWQubRzXB-pOSKM7WAjjBlL4PDY"]},
    ]

    # Starts an emptry ets
    :ets.new(:alertas, [:public, :named_table])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TeleWeather.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
