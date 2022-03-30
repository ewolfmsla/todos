defmodule SpawnServer do
  @moduledoc """
  genserver implementation
  """
  alias ToDos.List, as: ToDoList

  def start do
    Process.register(
      spawn(fn -> loop(ToDoList.new()) end),
      :todo_server
    )
  end

  def add_entry(new_entry) do
    send(:todo_server, {:add_entry, new_entry})
  end

  def get_by_id(id) do
    send(:todo_server, {:get_by_id, self(), id})

    receive do
      {:get_by_id, todo} -> todo
    end
  end

  def entries(date) do
    send(:todo_server, {:entries, self(), date})

    receive do
      {:entries, value} -> value
    after
      3000 -> {:error, :timeout}
    end
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        {:add_entry, new_entry} ->
          process_message(todo_list, {:add_entry, new_entry})

        {:entries, caller, date} ->
          process_message(todo_list, {:entries, caller, date})

        {:get_by_id, caller, id} ->
          process_message(todo_list, {:get_by_id, caller, id})

        _ ->
          todo_list
      end

    loop(new_todo_list)
  end

  defp process_message(todo_list, {:add_entry, entry}) do
    ToDoList.add_new(todo_list, entry)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:entries, ToDoList.entries(todo_list, date)})
    todo_list
  end

  defp process_message(todo_list, {:get_by_id, caller, id}) do
    send(caller, {:get_by_id, ToDoList.get_todo(todo_list, id)})
    todo_list
  end
end
