defmodule Heroku do
  @moduledoc """
  An API endpoint for Heroku.
  """

  use HTTPoison.Base

  @token Application.get_env(:po, __MODULE__)[:token]

  @spec process_request_headers(HTTPoison.headers) :: HTTPoison.headers
  def process_request_headers(headers) do
    headers
    |> add_header({"authorization", "Bearer #{@token}"})
    |> add_header({"accept", "application/vnd.heroku+json; version=3"})
    |> add_header({"content-type", "application/json"})
  end

  @spec process_request_body(any) :: iodata | no_return
  def process_request_body(body) when is_map(body), do: Poison.encode!(body)
  def process_request_body(body), do: body

  @spec process_response_body(iodata) :: Poison.Parser.t | no_return
  def process_response_body(body), do: Poison.decode!(body)

  @spec process_url(String.t) :: String.t
  def process_url(url), do: "https://api.heroku.com" <> url

  @spec add_header(HTTPoison.headers, {String.t, String.t}) :: HTTPoison.headers
  defp add_header(headers, header), do: [header | headers]
end
