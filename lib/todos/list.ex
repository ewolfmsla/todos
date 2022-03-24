defmodule ToDos.List do
  @moduledoc """
  Defines a struct representing todo items:

  defstruct auto_id: 1, entries: %{}
  """

  defstruct auto_id: 1, entries: %{}

  alias ToDos.Item, as: ToDoItem
  alias ToDos.List, as: ToDoList

  @type todo_list :: %ToDoList{
          auto_id: integer(),
          entries: %{integer() => %ToDoItem{date: Date.t(), id: integer(), title: String.t()}}
        }

  @type t(auto_id, entries) :: %ToDoList{auto_id: auto_id, entries: entries}

  @type t :: %ToDoList{auto_id: integer(), entries: %{integer() => ToDoItem.todo_item()}}

  @spec new() :: todo_list()
  def new(), do: %ToDoList{}

  @spec add_new(map(), ToDoItem.todo_item()) :: todo_list()
  def add_new(%ToDoList{} = todos, %ToDoItem{} = entry) do
    entry = Map.put(entry, :id, todos.auto_id)
    new_entries = Map.put(todos.entries, todos.auto_id, entry)

    %ToDoList{auto_id: todos.auto_id + 1, entries: new_entries}
  end

  @spec get_todo(todo_list(), integer()) :: ToDoItem.todo_item()
  def get_todo(todos, id) when is_integer(id) do
    Map.get(todos.entries, id, nil)
  end

  # entries: %{
  #   1 => %{date: ~D[2022-03-23], id: 1, title: "wake up"},
  #   2 => %{date: ~D[2022-03-22], id: 2, title: "go to work"},
  #   3 => %{date: ~D[2022-03-23], id: 3, title: "eat dinner"}
  # }

  @spec entries(todo_list(), String.t() | Date.t()) :: list(map())
  def entries(todos, title) when is_binary(title) do
    todos.entries
    |> Stream.filter(fn {_, entry} -> entry.title =~ title end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def entries(todos, date) do
    todos.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  @spec update(todo_list(), integer(), fun()) :: nil | :error | todo_list()
  def update(%ToDoList{} = todos, id, fun)
      when is_integer(id) and is_function(fun) do
    case Map.fetch(todos.entries, id) do
      {:ok, %{id: ^id} = current_entry} ->
        updated_entries = Map.put(todos.entries, id, fun.(current_entry))
        %ToDoList{todos | entries: updated_entries}

      :error ->
        nil
    end
  end

  def update(_, _, _), do: :error
end
