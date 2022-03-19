defmodule LiveChatWeb.UserController do
  use LiveChatWeb, :controller

  alias LiveChat.UserStore

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => %{"name" => username}}) do
    session_username = get_session(conn, :username)

    case UserStore.taken?(username) and session_username != username do
      true ->
        conn
        |> put_flash(:error, "Username is already taken")
        |> render(:new)

      false ->
        UserStore.remove(session_username)
        UserStore.put(username)

        conn
        |> put_session(:username, username)
        |> redirect(to: Routes.live_path(conn, LiveChatWeb.LobbyLive))
    end
  end
end
