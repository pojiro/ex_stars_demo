defmodule ExSTARSDemo do
  @moduledoc """
  Documentation for `ExSTARSDemo`.
  """

  use GenServer

  require Logger

  def gettime() do
    GenServer.call(__MODULE__, :gettime)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    stars_client_name = Keyword.fetch!(args, :stars_client_name)
    stars_client_key = Keyword.fetch!(args, :stars_client_key)

    ExSTARS.start_client(
      stars_client_name,
      stars_client_key,
      {192, 168, 0, 59},
      6057
    )

    {:ok,
     %{
       stars_client_name: stars_client_name,
       stars_client_key: stars_client_key,
       froms: %{}
     }}
  end

  def handle_info({ExSTARS.Client, _, message}, state) do
    %{stars_client_name: stars_client_name} = state

    lines = String.split(message, "\n", trim: true)

    state =
      Enum.reduce(lines, state, fn line, acc ->
        cond do
          # NOTE: `System>term1 ` 始まりなら server response
          String.starts_with?(line, "System>#{stars_client_name} ") ->
            line
            # NOTE: leader の `System>term1 ` を trim
            |> String.trim_leading("System>#{stars_client_name} ")
            # NOTE: @gettime 2024-11-23 14:51:59 を `handle_server_response` へ
            |> handle_server_response(acc)

          true ->
            handle_unknown_response(line)
            acc
        end
      end)

    {:noreply, state}
  end

  def handle_call(:gettime, from, state) do
    %{stars_client_name: stars_client_name} = state
    ExSTARS.send(stars_client_name, "System gettime")
    {:noreply, %{state | froms: Map.put(state.froms, :gettime, from)}}
  end

  defp handle_server_response("@gettime " <> time, state) do
    if is_nil(state.froms.gettime) do
      state
    else
      GenServer.reply(state.froms.gettime, time)
      %{state | froms: %{gettime: nil}}
    end
  end

  defp handle_server_response("Ok:", state) do
    state
  end

  defp handle_unknown_response(line) do
    Logger.warning("unknown response: #{line}")
  end
end
