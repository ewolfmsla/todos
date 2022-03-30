defmodule ToDos.Application do
  use Application

  def start(_type, args) do
    children = [{ToDoServer, args}]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
