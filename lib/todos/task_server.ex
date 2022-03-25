defmodule TaskServer do
  @moduledoc """
  simple task server
  """

  def start() do
    connection = :rand.uniform(1000)
    pid = spawn(fn -> loop(connection) end)
    {:ok, %{pid: pid, connection: connection}}
  end

  def run_async(server_pid, query_def) do
    send(server_pid, {:run_query, self(), query_def})
  end

  def get_result() do
    receive do
      {:query_result, result} -> result
    after
      2000 ->
        {:error, :timeout}
    end
  end

  defp loop(connection) do
    receive do
      {:run_query, caller, query_def} ->
        send(caller, {:query_result, run_query(connection, query_def)})
    end

    loop(connection)
  end

  defp run_query(connection, query_def) do
    Process.sleep(2000)
    times = :rand.uniform(10)
    result = for x <- 1..times, do: x
    {:ok, %{connection: connection, query_def: query_def, result: result}}
  end
end
