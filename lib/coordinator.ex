require Logger

defmodule Metex.Coordinator do
  @moduledoc """
  The coordinator holding state for the child process.
  """
  def loop(results \\ [], results_expected) do
    receive do
      {:ok, result} ->
        new_results = [result | results]

        if results_expected === Enum.count(new_results) do
          send(self(), :exit)
        end

        loop(new_results, results_expected)

      :exit ->
        # IO.puts(results |> Enum.sort() |> Enum.join(", "))
        # results
        Enum.each(results, fn loc -> loc["main"]["temp"] |> IO.puts() end)

      _ ->
        loop(results, results_expected)
    end
  end
end
