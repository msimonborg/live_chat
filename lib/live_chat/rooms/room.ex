defmodule LiveChat.Rooms.Room do
  use Ecto.Schema

  import Ecto.Changeset

  alias LiveChat.Messages.Message

  schema "rooms" do
    field :created_by, :string
    field :description, :string
    field :name, :string

    has_many :messages, Message

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :description, :created_by])
    |> validate_required([:name, :created_by])
    |> unique_constraint(:name)
  end
end
