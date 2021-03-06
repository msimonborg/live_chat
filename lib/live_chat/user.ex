defmodule LiveChat.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias LiveChat.User
  alias LiveChatWeb.UserAuth

  embedded_schema do
    field :name, :string
  end

  def changeset(user \\ %User{}, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_change(:name, fn :name, name ->
      if UserAuth.online?(name), do: [name: "already taken"], else: []
    end)
  end

  def changeset, do: changeset(%{})
end
