defmodule LiveChatWeb.RoomLive do
  use LiveChatWeb, :live_view

  alias LiveChat.Messages
  alias LiveChat.Messages.Message
  alias LiveChat.Rooms
  alias LiveChatWeb.Presence
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
          "inline w-3/4 sm:w-5/6 justify-center text-md mb-4 max-w-full border border-gray-300 rounded-md"
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
          <%= submit class: "inline pt-1 pb-3 px-3 border border-transparent rounded-md bg-indigo-600 text-white hover:bg-indigo-700" do %>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path d="M10.894 2.553a1 1 0 00-1.788 0l-7 14a1 1 0 001.169 1.409l5-1.429A1 1 0 009 15.571V11a1 1 0 112 0v4.571a1 1 0 00.725.962l5 1.428a1 1 0 001.17-1.408l-7-14z" />
            </svg>
          <% end %>
        </div>
      </.form>

      <%= for name <- @typing do %>
        <p><%= name %> is typing...</p>
      <% end %>

      <h1 class="relative flex justify-center text-xl my-4">Users in this room:</h1>
      <div class="w-full my-4 h-24 border border-solid rounded-md border-gray-500 overflow-y-auto">
        <%= for user <- @users_in_room do %>
          <p class="break-words my-1"><%= user %></p>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    room = Rooms.get_room!(id, preload: [:messages])
    changeset = Messages.change_message(%Message{})
    topic = topic(id)
    Presence.track(self(), topic, socket.assigns.name, %{})
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
      |> assign(:users_in_room, users_in_room(topic))

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

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff"}, socket) do
    {:noreply, assign(socket, :users_in_room, users_in_room(socket.assigns.topic))}
  end

  defp topic(id), do: "room:#{id}"

  defp format_local_time(naive_datetime, timezone) do
    naive_datetime
    |> Timex.to_datetime()
    |> Timex.Timezone.convert(timezone)
    |> Timex.format!("%I:%M %p", :strftime)
  end

  defp users_in_room(topic) do
    topic
    |> Presence.list()
    |> Map.keys()
  end
end
