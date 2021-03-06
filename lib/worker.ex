defmodule Metex.Worker do
  @moduledoc """
  Worker that spawns the http requests.
  """
  def loop do
    receive do
      {sender_pid, location} ->
        send(sender_pid, {:ok, raw_data(location)})

      _ ->
        IO.puts("Dont't know how to process this message.")
    end

    loop()
  end

  def temperature_of(location) do
    result = location |> url_for |> HTTPoison.get() |> parse_response

    case result do
      {:ok, temp} ->
        "#{location}: #{temp}C"

      :error ->
        "#{location} not found"
    end
  end

  def raw_data(location) do
    result = location |> url_for |> HTTPoison.get()

    case result do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        body |> JSON.decode!()

      :error ->
        "#{location} not found"
    end
  end

  defp url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{apikey()}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode!() |> compute_temperature
  end

  defp parse_response(_) do
    :error
  end

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round()
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  defp apikey do
    System.get_env("WEATHER_API")
  end
end
