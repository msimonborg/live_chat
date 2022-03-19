defmodule LiveChat.UserStore do
  use GenServer

  @name __MODULE__
  # ---- Client API ----

  def start_link(init_arg) do
    GenServer.start_link(@name, init_arg, name: @name)
  end

  def list do
    GenServer.call(@name, :list)
  end

  def taken?(username) do
    GenServer.call(@name, {:taken?, username})
  end

  def put(username) do
    GenServer.cast(@name, {:put, username})
  end

  def remove(username) do
    GenServer.cast(@name, {:remove, username})
  end

  # ---- Server Callbacks ----

  @impl true
  def init(_init_arg) do
    {:ok, []}
  end

  @impl true
  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:taken?, username}, _from, state) do
    {:reply, username in state, state}
  end

  @impl true
  def handle_cast({:put, username}, state) do
    new_state =
      case Enum.member?(state, username) do
        true -> state
        false -> [username | state]
      end

    {:noreply, new_state}
  end

  def handle_cast({:remove, username}, state) do
    {:noreply, List.delete(state, username)}
  end
end
