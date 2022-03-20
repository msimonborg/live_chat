defmodule LiveChatWeb.UserAuth do
  import Phoenix.LiveView

  alias LiveChatWeb.Presence
  alias LiveChatWeb.Router.Helpers, as: Routes
  alias Phoenix.PubSub

  @pubsub LiveChat.PubSub
  @pubsub_topic "lobby"
  @presence_topic "users_online"

  def on_mount(:default, _params, session, socket) do
    name = Map.get(session, "username")
    Process.send(self(), {:authorize, name}, [])

    socket =
      socket
      |> authorization_hook()
      |> assign(:name, name)

    {:cont, socket}
  end

  def online?(name) do
    users_online()
    |> Enum.member?(name)
  end

  def users_online do
    @presence_topic
    |> Presence.list()
    |> Map.keys()
  end

  def online_user_count, do: length(users_online())

  defp authorization_hook(socket) do
    attach_hook(socket, :authorize, :handle_info, fn
      {:authorize, name}, socket ->
        socket =
          case online?(name) or is_nil(name) do
            true ->
              socket
              |> put_flash(:error, "Pick a new username")
              |> redirect(to: Routes.user_path(socket, :new))

            false ->
              Presence.track(self(), @presence_topic, name, %{})
              PubSub.broadcast(@pubsub, @pubsub_topic, :user_change)
              socket
          end

        {:halt, detach_hook(socket, :authorize, :handle_info)}

      _info, socket ->
        {:cont, socket}
    end)
  end
end
