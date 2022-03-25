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

  @spec new(list(ToDoItem.todo_item())) :: todo_list()
  def new(todo_items \\ []) do
    case todo_items do
      [] ->
        %ToDoList{}

      _ ->
        # Enum.reduce(todo_items, ToDoList.new(), fn item, acc -> ToDoList.add_new(acc, item) end)
        Enum.reduce(todo_items, ToDoList.new(), &add_new(&2, &1))
    end
  end

  @spec add_new(todo_list(), ToDoItem.todo_item()) :: todo_list()
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

  @doc """
  loads a csv file in the format

  mm/dd/yyyy, todo item 1\n
  mm/dd/yyyy, todo item 2

  and returns a %ToDo.List{} struct
  """
  @spec load(String.t()) :: todo_list() | :error
  def load(csv) do
    try do
      File.stream!(csv)
      |> Stream.map(&String.replace(&1, "\n", ""))
      |> Stream.map(&String.split(&1, ",", parts: 2, trim: true))
      |> Stream.map(&format_date_and_do_trim/1)
      |> Enum.map(&to_todo_item/1)
      |> ToDoList.new()
    rescue
      FunctionClauseError -> :error
    end
  end

  defp to_todo_item(line) when is_list(line),
    do: %ToDoItem{date: Enum.at(line, 0), title: Enum.at(line, 1)}

  defp format_date_and_do_trim(list) do
    fe = Enum.at(list, 0) |> String.split("/")
    fe = "#{Enum.at(fe, 2)}-#{Enum.at(fe, 0)}-#{Enum.at(fe, 1)}"
    se = String.trim(Enum.at(list, 1))

    [fe, se]
  end

  @spec remove(todo_list(), integer()) :: todo_list()
  def remove(%ToDoList{} = todos, id) when is_integer(id) do
    updated_entries =
      todos.entries
      |> Stream.filter(&(elem(&1, 0) != id))
      |> Enum.reduce(%{}, fn {key, val}, acc -> Map.put(acc, key, val) end)

    %ToDoList{todos | entries: updated_entries}
  end

  def remove(%ToDoList{} = todos, _), do: todos
end
