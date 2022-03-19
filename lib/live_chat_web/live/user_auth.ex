defmodule LiveChatWeb.UserAuth do
  import Phoenix.LiveView

  alias LiveChatWeb.Presence
  alias LiveChatWeb.Router.Helpers, as: Routes

  @topic "users_online"

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
    @topic
    |> Presence.list()
    |> Map.keys()
    |> Enum.member?(name)
  end

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
              Presence.track(self(), @topic, name, %{})
              socket
          end

        {:halt, detach_hook(socket, :authorize, :handle_info)}

      _info, socket ->
        {:cont, socket}
    end)
  end
end
