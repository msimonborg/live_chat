defmodule LiveChat.Messages.Message do
  use Ecto.Schema

  import Ecto.Changeset

  alias LiveChat.Rooms.Room

  schema "messages" do
    field :body, :string
    field :created_by, :string

    belongs_to :room, Room

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body, :created_by, :room_id])
    |> validate_required([:body, :created_by])
  end
end
