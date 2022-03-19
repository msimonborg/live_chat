defmodule LiveChatWeb.LobbyLive do
  use LiveChatWeb, :live_view

  alias LiveChat.UserStore

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Hello <%= @name %></h1>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    case Map.get(session, "username") do
      nil ->
        {:ok, push_redirect(socket, to: Routes.user_path(socket, :new))}

      name ->
        if UserStore.taken?(name) do
          {:ok, assign(socket, :name, name)}
        else
          {:ok, push_redirect(socket, to: Routes.user_path(socket, :new))}
        end
    end
  end
end
