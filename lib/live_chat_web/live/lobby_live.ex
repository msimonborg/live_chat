defmodule LiveChatWeb.LobbyLive do
  use LiveChatWeb, :live_view

  import LiveChatWeb.UserAuth, only: [online_user_count: 0]

  alias LiveChat.Rooms
  alias LiveChat.Rooms.Room
  alias LiveChatWeb.RoomLive
  alias Phoenix.PubSub

  @pubsub LiveChat.PubSub
  @topic "lobby"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-auto p-8">
        <h1 class="relative flex justify-center text-2xl my-4">Hello <%= @name %></h1>
        <h3 class="relative flex justify-center text-md my-4"><%= display_online_user_count(@online_user_count) %></h3>
        <h2 class="relative flex justify-center text-lg my-4">Create a new room</h2>
      <.form let={f} for={@changeset} phx-change="validate" phx-submit="save">
        <div class="block">
          <%= label f, :name, class: "text-md w-full block" %>
          <%= text_input f, :name, class: "relative flex justify-center text-md mb-4 w-full block border border-gray-300 rounded-md" %>
          <div class="mt-4 -mb-2">
            <%= error_tag f, :name %>
          </div>
        </div>

        <div class="block">
          <%= label f, :description, class: "text-md w-full block" %>
          <%= textarea f, :description, placeholder: "Optional", class: "relative flex justify-center text-md mb-4 w-full block border border-gray-300 rounded-md" %>
          <div class="mt-4 -mb-2">
            <%= error_tag f, :description %>
          </div>
        </div>

        <%= hidden_input f, :created_by, value: @name %>
        <%= submit "Create room", class: "px-4 py-2 border border-transparent rounded-md bg-indigo-600 text-white hover:bg-indigo-700"%>
      </.form>
      <div class="w-full h-auto py-8">
        <%= unless Enum.empty?(@rooms) do %>
          <h2 class="text-lg sm:text-xl">Join a room</h2>
          <ul>
            <%= for room <- @rooms do %>
              <li><a class="text-indigo-600 hover:text-indigo-800" href={Routes.live_path(@socket, RoomLive, room)}><%= room.name %> - created by <%= room.created_by %></a></li>
            <% end %>
          </ul>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    rooms = Rooms.list_rooms() |> Enum.reverse()
    changeset = Rooms.change_room(%Room{})
    PubSub.subscribe(@pubsub, @topic)

    socket =
      socket
      |> assign(:rooms, rooms)
      |> assign(:changeset, changeset)
      |> assign(:online_user_count, online_user_count())

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"room" => room_params}, socket) do
    changeset = Rooms.change_room(%Room{}, room_params) |> Map.put(:action, :insert)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"room" => room_params}, socket) do
    case Rooms.create_room(room_params) do
      {:ok, room} ->
        PubSub.broadcast(@pubsub, @topic, {:put, room})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def handle_info({:put, room}, socket) do
    rooms = [room | socket.assigns.rooms]
    {:noreply, assign(socket, :rooms, rooms)}
  end

  def handle_info(:user_change, socket) do
    {:noreply, assign(socket, :online_user_count, online_user_count())}
  end

  @impl true
  def terminate(_reason, _socket) do
    PubSub.broadcast(@pubsub, @topic, :user_change)
    :ok
  end

  defp display_online_user_count(count) do
    case count do
      0 -> "There is no one online."
      1 -> "You are the only user online."
      2 -> "There is 1 other user online."
      num -> "There are #{num - 1} other users online."
    end
  end
end
