defmodule ToDoProcess do
  @moduledoc """
  genserver implementation
  """
  alias ToDos.List, as: ToDoList

  # client implementation

  def start do
    start(ToDoProcess)
  end

  @spec init() :: ToDoList.t()
  def init(), do: ToDoList.new()

  def add_entry(todo_server, new_entry) do
    cast(todo_server, {:add_entry, new_entry})
  end

  def delete_entry(todo_server, id) do
    call(todo_server, {:remove, id})
  end

  def get_entry(todo_server, id) do
    call(todo_server, {:get_entry, id})
  end

  def entries(todo_server, date) do
    call(todo_server, {:entries, date})
  end

  def handle_call({:entries, date}, state) do
    {ToDoList.entries(state, date), state}
  end

  def handle_call({:get_entry, id}, state) do
    case ToDoList.get_todo(state, id) do
      nil -> {:none, state}
      entry -> {entry, state}
    end
  end

  def handle_call({:remove, id}, state) do
    {:ok, ToDoList.remove(state, id)}
  end

  def handle_cast({:add_entry, new_entry}, state) do
    ToDoList.add_new(state, new_entry)
  end

  # server implementation

  defp start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  defp call(server_pid, request) do
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} -> response
    end
  end

  defp cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} = callback_module.handle_call(request, current_state)
        send(caller, {:response, response})
        loop(callback_module, new_state)

      {:cast, request} ->
        new_state = callback_module.handle_cast(request, current_state)
        loop(callback_module, new_state)
    end
  end
end
