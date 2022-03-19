defmodule LiveChat.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :created_by, :string
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :description, :created_by])
    |> validate_required([:name, :description, :created_by])
    |> unique_constraint(:name)
  end
end
