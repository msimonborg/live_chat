defmodule LiveChatWeb.RoomLive do
  use LiveChatWeb, :live_view

  alias LiveChat.Rooms

  @impl true
  def render(assigns) do
    ~H"""
    <h1><%= @room.name %></h1>
    <p>Hello <%= @name %></p>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    room = Rooms.get_room!(id, preload: [:messages])
    {:ok, assign(socket, :room, room)}
  end
end
