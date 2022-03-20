defmodule LiveChatWeb.RoomLive do
  use LiveChatWeb, :live_view

  alias LiveChat.Messages
  alias LiveChat.Messages.Message
  alias LiveChat.Rooms
  alias Phoenix.PubSub

  @pubsub LiveChat.PubSub

  @impl true
  def render(assigns) do
    input_opts =
      if assigns.refresh_input do
        [value: ""]
      else
        []
      end
      |> Keyword.merge(
        placeholder: "Message",
        id: "message-input",
        class:
          "relative flex justify-center text-md mb-4 w-full block border border-gray-300 rounded-md"
      )

    assigns = assign(assigns, :input_opts, input_opts)

    ~H"""
    <div class="w-full h-auto p-8">
      <h1 class="relative flex justify-center text-xl my-4"><%= @room.name %></h1>
      <h2 class="relative flex justify-center text-md my-4"><%= @room.description %></h2>

      <div class="w-full h-80 sm:h-96 border border-solid rounded-md border-gray-500 overflow-y-auto" phx-hook="ChatRoom" id="chat-box">
        <div class="flex flex-col-reverse justify-end h-full">
          <%= for message <- @messages do %>
            <p class="break-words my-1"><%= "#{format_local_time(message.inserted_at, @local_timezone)} - #{message.created_by} - #{message.body}" %></p>
          <% end %>
        </div>
      </div>

      <div class="w-full h-auto pt-8 pb-2">
        <p>What's on your mind, <%= @name %>?</p>
      </div>

      <.form let={f} for={@changeset} phx-change="input" phx-submit="save">
        <div class="block">
          <%= text_input f, :body, @input_opts %>
          <%= hidden_input f, :created_by, value: @name %>
          <%= submit "Send", class: "w-full py-1 border border-transparent rounded-md bg-indigo-600 text-white hover:bg-indigo-700" %>
        </div>
      </.form>

      <%= for name <- @typing do %>
        <p><%= name %> is typing...</p>
      <% end %>
    </div>
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
      |> assign(:messages, Enum.reverse(room.messages))
      |> assign(:changeset, changeset)
      |> assign(:topic, topic)
      |> assign(:typing, [])
      |> assign(:refresh_input, false)
      |> assign(:local_timezone, "Etc/UTC")

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
    {:noreply, assign(socket, :refresh_input, false)}
  end

  def handle_event("save", %{"message" => message_params}, socket) do
    room = socket.assigns.room
    {:ok, message} = Messages.publish_message_to_room(room, message_params)
    changeset = Messages.change_message(%Message{})

    topic = socket.assigns.topic
    name = socket.assigns.name
    PubSub.broadcast(@pubsub, topic, {:not_typing, name})
    PubSub.broadcast(@pubsub, topic, {:new_message, message})

    {:noreply, assign(socket, changeset: changeset, refresh_input: true)}
  end

  def handle_event("local_timezone", %{"local_timezone" => local_timezone}, socket) do
    {:noreply, assign(socket, :local_timezone, local_timezone)}
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
    socket = update(socket, :messages, fn messages -> [message | messages] end)
    {:noreply, socket}
  end

  def handle_info({:not_typing, name}, socket) do
    {:noreply, update(socket, :typing, fn typing -> List.delete(typing, name) end)}
  end

  defp topic(id), do: "room:#{id}"

  defp format_local_time(naive_datetime, timezone) do
    naive_datetime
    |> Timex.to_datetime()
    |> Timex.Timezone.convert(timezone)
    |> Timex.format!("%I:%M %p", :strftime)
  end
end
