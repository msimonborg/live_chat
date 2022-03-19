defmodule LiveChatWeb.AssignUser do
  import Phoenix.LiveView

  alias LiveChat.UserStore
  alias LiveChatWeb.Router.Helpers, as: Routes

  def on_mount(:default, _params, session, socket) do
    name = Map.get(session, "username")

    if UserStore.taken?(name) do
      {:cont, assign(socket, name: name)}
    else
      {:halt, push_redirect(socket, to: Routes.user_path(socket, :new))}
    end
  end
end
