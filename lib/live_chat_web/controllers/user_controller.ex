defmodule LiveChatWeb.UserController do
  use LiveChatWeb, :controller

  alias LiveChatWeb.UserAuth

  def new(conn, _params) do
    conn
    |> put_session(:username, nil)
    |> render("new.html")
  end

  def create(conn, %{"user" => %{"name" => username}}) do
    case UserAuth.online?(username) do
      true ->
        conn
        |> put_flash(:error, "Username is already taken")
        |> render(:new)

      false ->
        conn
        |> put_session(:username, username)
        |> redirect(to: Routes.live_path(conn, LiveChatWeb.LobbyLive))
    end
  end
end
