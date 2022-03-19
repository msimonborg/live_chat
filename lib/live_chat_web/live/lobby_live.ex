defmodule LiveChatWeb.LobbyLive do
  use LiveChatWeb, :live_view

  alias LiveChat.Rooms
  alias LiveChat.Rooms.Room
  alias LiveChat.UserStore
  alias LiveChatWeb.RoomLive
  alias Phoenix.PubSub

  @pubsub LiveChat.PubSub
  @topic "lobby"

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Hello <%= @name %></h1>
    <h2>Create a new room</h2>
    <.form let={f} for={@changeset} phx-change="validate" phx-submit="save">
      <%= label f, :name %>
      <%= text_input f, :name %>
      <%= error_tag f, :name %>

      <%= label f, :description %>
      <%= textarea f, :description, placeholder: "Optional" %>
      <%= error_tag f, :description %>

      <%= submit "Create room" %>
    </.form>
    <%= unless Enum.empty?(@rooms) do %>
      <h2>Join a room:</h2>
      <ul>
        <%= for room <- @rooms do %>
          <li><a href={Routes.live_path(@socket, RoomLive, room)}><%= room.name %> - created by <%= room.created_by %></a></li>
        <% end %>
      </ul>
    <% end %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    rooms = Rooms.list_rooms()
    changeset = Rooms.change_room(%Room{})
    PubSub.subscribe(@pubsub, @topic)
    {:ok, assign(socket, rooms: rooms, changeset: changeset)}
  end

  @impl true
  def handle_event("validate", %{"room" => room_params}, socket) do
    changeset = Rooms.change_room(%Room{}, room_params) |> Map.put(:action, :insert)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"room" => room_params}, socket) do
    create_attrs = Map.put(room_params, "created_by", socket.assigns.name)

    case Rooms.create_room(create_attrs) do
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

  @impl true
  def terminate(_reason, socket) do
    UserStore.remove(socket.assigns.name)
  end
end
