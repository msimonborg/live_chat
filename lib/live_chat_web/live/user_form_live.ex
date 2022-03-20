defmodule LiveChatWeb.UserFormLive do
  use LiveChatWeb, :live_view

  alias LiveChat.User
  alias LiveChatWeb.UserAuth

  @impl true
  def render(assigns) do
    opts =
      if assigns.changeset.valid? do
        [
          disabled: false,
          class:
            "w-full py-1 border border-transparent rounded-md bg-indigo-600 text-white hover:bg-indigo-700"
        ]
      else
        [
          disabled: true,
          class: "w-full py-1 border border-transparent rounded-md bg-indigo-300 text-white"
        ]
      end

    assigns = assign(assigns, :opts, opts)

    ~H"""
    <div class="w-full">
      <.form let={f} for={@changeset} phx-change="validate" action={"/"}>
        <%= text_input f, :name, class: "relative flex justify-center text-md my-4 w-full block border border-gray-300 rounded-md" %>
        <div class="mt-4 -mb-2">
          <%= error_tag f, :name %>
        </div>

        <%= submit "Join", @opts %>
      </.form>
    </div>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    session_username =
      session
      |> Map.get("username")
      |> check_user_presence()

    changeset = User.changeset(%User{name: session_username}, %{})

    socket =
      socket
      |> assign(:session_username, session_username)
      |> assign(:changeset, changeset)

    {:ok, socket, layout: false}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    session_username = socket.assigns.session_username |> check_user_presence()

    changeset =
      %User{name: session_username}
      |> User.changeset(user_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  defp check_user_presence(name) do
    case UserAuth.online?(name) do
      false -> name
      true -> nil
    end
  end
end
