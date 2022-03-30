defmodule ToDoServer do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: :todos)
  end

  def start() do
    GenServer.start_link(__MODULE__, [])
  end

  def push(pid, element) do
    GenServer.cast(pid, {:push, element})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  def items(pid) do
    GenServer.call(pid, :all)
  end

  @impl true
  def init(list) do
    IO.inspect(list)
    {:ok, list}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_call(:all, _from, list) do
    {:reply, list, list}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end
end
