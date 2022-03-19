defmodule LiveChat.RoomsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LiveChat.Rooms` context.
  """

  @doc """
  Generate a unique room name.
  """
  def unique_room_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    {:ok, room} =
      attrs
      |> Enum.into(%{
        created_by: "some created_by",
        description: "some description",
        name: unique_room_name()
      })
      |> LiveChat.Rooms.create_room()

    room
  end
end
