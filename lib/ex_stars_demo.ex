defmodule ExSTARSDemo do
  @moduledoc """
  Documentation for `ExSTARSDemo`.
  """

  use GenServer

  require Logger

  def send(message) do
    GenServer.call(__MODULE__, {:send, message})
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
       stars_client_key: stars_client_key
     }}
  end

  def handle_call({:send, message}, _from, state) do
    %{stars_client_name: stars_client_name} = state
    ExSTARS.send(stars_client_name, message)
    {:reply, :ok, state}
  end

  def handle_info({ExSTARS.Client, _, message}, state) do
    %{stars_client_name: stars_client_name} = state

    message
    |> String.split("\n", trim: true)
    |> Enum.each(fn response -> handle_response(response, stars_client_name) end)

    {:noreply, state}
  end

  def handle_response("System>" <> _ = response, stars_client_name) do
    response
    |> String.trim_leading("System>#{stars_client_name} ")
    |> handle_server_response()
  end

  def handle_response("Contecnano.ai.ch3>" <> _ = response, stars_client_name) do
    response
    |> String.trim_leading("Contecnano.ai.ch3>#{stars_client_name} ")
    |> handle_contecnano_ai_ch_response(3)
  end

  def handle_response(response, _stars_client_name) do
    Logger.warning("unhandled response: #{response}")
  end

  defp handle_server_response("@gettime " <> time) do
    [date, time] = String.split(time, " ")
    DateTime.from_iso8601("#{date}T#{time}+09:00")
  end

  defp handle_server_response(message) do
    Logger.debug("Unhandled server response: #{message}")
  end

  defp handle_contecnano_ai_ch_response("@GetValue " <> value, 3 = _ch) do
    String.to_float(value)
  end
end
