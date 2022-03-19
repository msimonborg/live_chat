defmodule LiveChatWeb.UserFormLive do
  use LiveChatWeb, :live_view

  alias LiveChat.User

  @impl true
  def render(assigns) do
    disabled = unless assigns.changeset.valid?, do: true, else: false
    assigns = assign(assigns, :disabled, disabled)

    ~H"""
    <.form let={f} for={@changeset} phx-change="validate" action={"/"} >
      <%= text_input f, :name %>
      <%= error_tag f, :name %>

      <%= submit "Join", disabled: @disabled %>
    </.form>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    session_username = Map.get(session, "username")
    changeset = User.changeset(%User{name: session_username}, %{})

    socket =
      socket
      |> assign(:session_username, session_username)
      |> assign(:changeset, changeset)

    {:ok, socket, layout: false}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    session_username = socket.assigns.session_username

    changeset =
      %User{name: session_username}
      |> User.changeset(user_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, :changeset, changeset)}
  end
end