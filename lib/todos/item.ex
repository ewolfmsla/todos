defmodule ToDos.Item do
  @moduledoc """
  Defines a struct representing a todo item

  defstruct date: nil, id: nil, title: nil
  """
  defstruct date: nil, id: nil, title: nil

  alias ToDos.Item, as: ToDoItem

  @type todo_item() :: %ToDoItem{date: Date.t(), id: integer(), title: String.t()}
end
