defmodule LiveChatWeb.UserAuth do
  import Phoenix.LiveView

  alias LiveChat.UserStore
  alias LiveChatWeb.Presence
  alias LiveChatWeb.Router.Helpers, as: Routes

  @topic "users_online"

  def on_mount(:default, _params, session, socket) do
    name = Map.get(session, "username")

    if online?(name) do
      socket =
        socket
        |> put_flash(:error, "Username is already taken")
        |> push_redirect(to: Routes.user_path(socket, :new))

      {:halt, socket}
    else
      Presence.track(self(), @topic, name, %{})
      UserStore.put(name)
      {:cont, assign(socket, name: name)}
    end
  end

  def online?(name) do
    @topic
    |> Presence.list()
    |> Map.keys()
    |> Enum.member?(name)
  end
end
