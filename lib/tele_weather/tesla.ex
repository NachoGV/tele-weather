defmodule TeslaApi do
  use Tesla
  @adapter Tesla.Adapter.Hackney

  defp token_aemet() do
    "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJpZ25hY2lvLmd2YWx2ZXJkZUBnbWFpbC5jb20iLCJqdGkiOiJmYWNiZWJiMS02ZTE1LTQ4Y2YtOTkwNy02ZTllN2NjOGFlZGEiLCJpc3MiOiJBRU1FVCIsImlhdCI6MTY1MTMzODgxMiwidXNlcklkIjoiZmFjYmViYjEtNmUxNS00OGNmLTk5MDctNmU5ZTdjYzhhZWRhIiwicm9sZSI6IiJ9.1J5Bg2Ybtup0cviQTfCT_etUY3A_iNZKjUH8y3oVmV8"
  end

  def new_base(token \\ token_aemet()) do
    middleware = [
      {Tesla.Middleware.Timeout, timeout: 10000},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"api_key", "#{token}"}, {"Content-Type", "application/json"}]}
    ]
    Tesla.client(middleware, @adapter)
  end

  def new(token \\ token_aemet()) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://opendata.aemet.es/opendata/"},
      {Tesla.Middleware.Timeout, timeout: 10000},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"api_key", "#{token}"}, {"Content-Type", "application/json"}]}
    ]
    Tesla.client(middleware, @adapter)
  end

  def get_muni(url) do
    Tesla.get(new(), url)
  end

  def get_muni_base(url) do
    Tesla.get(new_base(), url)
  end

end
