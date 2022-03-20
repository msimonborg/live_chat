defmodule LiveChatWeb.RoomLive do
  use LiveChatWeb, :live_view

  alias LiveChat.Messages
  alias LiveChat.Messages.Message
  alias LiveChat.Rooms
  alias Phoenix.PubSub

  @pubsub LiveChat.PubSub

  @impl true
  def render(assigns) do
    ~H"""
    <h1><%= @room.name %></h1>
    <h3><%= @room.description %></h3>

    <textarea rows="8" class="chat-box">
      <%= for message <- @messages do %>
        <%= message.created_by %> - <%= message.body %>
      <% end %>
    </textarea>

    <p>What's on your mind, <%= @name %>?</p>

    <.form let={f} for={@changeset} phx-change="input" phx-submit="save">
      <%= textarea f, :body, placeholder: "Message" %>
      <%= hidden_input f, :created_by, value: @name %>
      <%= submit "Send" %>
    </.form>

    <%= for name <- @typing do %>
      <p><%= name %> is typing...</p>
    <% end %>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    room = Rooms.get_room!(id, preload: [:messages])
    changeset = Messages.change_message(%Message{})
    topic = topic(id)
    PubSub.subscribe(@pubsub, topic)

    socket =
      socket
      |> assign(:room, room)
      |> assign(:messages, room.messages)
      |> assign(:changeset, changeset)
      |> assign(:topic, topic)
      |> assign(:typing, [])

    {:ok, socket}
  end

  @impl true
  def handle_event("input", %{"message" => %{"body" => message_body}}, socket) do
    topic = socket.assigns.topic
    name = socket.assigns.name

    pubsub_msg =
      if message_body && String.length(message_body) > 0 do
        {:typing, name}
      else
        {:not_typing, name}
      end

    PubSub.broadcast(@pubsub, topic, pubsub_msg)
    {:noreply, socket}
  end

  def handle_event("save", %{"message" => message_params}, socket) do
    room = socket.assigns.room
    topic = socket.assigns.topic
    name = socket.assigns.name
    {:ok, message} = Messages.publish_message_to_room(room, message_params)
    PubSub.broadcast(@pubsub, topic, {:not_typing, name})
    PubSub.broadcast(@pubsub, topic, {:new_message, message})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:typing, name}, socket) do
    socket =
      if name == socket.assigns.name or name in socket.assigns.typing do
        socket
      else
        update(socket, :typing, fn typing -> [name | typing] end)
      end

    {:noreply, socket}
  end

  def handle_info({:new_message, message}, socket) do
    socket = update(socket, :messages, fn messages -> List.insert_at(messages, -1, message) end)
    {:noreply, socket}
  end

  def handle_info({:not_typing, name}, socket) do
    {:noreply, update(socket, :typing, fn typing -> List.delete(typing, name) end)}
  end

  defp topic(id), do: "room:#{id}"
end
