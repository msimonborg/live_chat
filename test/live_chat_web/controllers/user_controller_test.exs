defmodule LiveChatWeb.UserControllerTest do
  use LiveChatWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to LiveChat!"
  end
end
