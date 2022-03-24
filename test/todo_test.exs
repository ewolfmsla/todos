defmodule ToDoTest do
  use ExUnit.Case, async: true

  alias ToDos.Item, as: ToDoItem
  alias ToDos.List, as: ToDoList

  setup_all do
    todos =
      ToDoList.new()
      |> ToDoList.add_new(%ToDoItem{date: ~D[2022-03-23], title: "wake up"})
      |> ToDoList.add_new(%ToDoItem{date: ~D[2022-03-22], title: "go to work"})
      |> ToDoList.add_new(%ToDoItem{date: ~D[2022-03-23], title: "eat dinner"})

    {:ok, todos: todos}
  end

  test "new/0" do
    assert %ToDoList{} == ToDoList.new()
  end

  test "add_new/3", %{todos: todos} do
    assert 3 == length(Map.keys(todos.entries))
  end

  test "get_todo", %{todos: todos} do
    todos = ToDoList.get_todo(todos, 2)

    %{date: _date, title: title} = todos

    assert "go to work" == title
  end

  test "get_todos/2 by date 1", %{todos: todos} do
    [%{date: _date, title: title}] = ToDoList.entries(todos, ~D[2022-03-22])

    assert "go to work" == title
  end

  test "get_todos/2 by date 2", %{todos: todos} do
    [%{title: title_1}, %{title: title_2}] = ToDoList.entries(todos, ~D[2022-03-23])

    assert "wake up" == title_1
    assert "eat dinner" == title_2
  end

  test "get_todos/2 by title 2", %{todos: todos} do
    [%{title: title}] = ToDoList.entries(todos, "work")

    assert "go to work" == title
  end

  test "update/3", %{todos: todos} do
    assert %{id: 2, title: "go to work"} = ToDoList.get_todo(todos, 2)

    todos = ToDoList.update(todos, 2, &Map.put(&1, :title, "call in sick"))

    %{id: 2, title: title} = ToDoList.get_todo(todos, 2)

    assert "call in sick" == title

    # updater_func = fn entry ->
    #   Map.put(entry, :date, ~D[2020-11-04]) |> Map.put(:title, "hell yeah!")
    # end

    updater_func = &(Map.put(&1, :date, ~D[2020-11-04]) |> Map.put(:title, "hell yeah!"))

    todos = ToDoList.update(todos, 2, updater_func)

    %{date: date, title: title} = ToDoList.get_todo(todos, 2)

    assert ~D[2020-11-04] == date
    assert "hell yeah!" = title
  end
end