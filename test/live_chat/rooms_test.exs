defmodule LiveChat.RoomsTest do
  use LiveChat.DataCase

  alias LiveChat.Rooms

  describe "rooms" do
    import LiveChat.RoomsFixtures

    alias LiveChat.{Messages, MessagesFixtures}
    alias LiveChat.Rooms.Room

    @invalid_attrs %{created_by: nil, description: nil, name: nil}

    test "list_rooms/0 returns all rooms" do
      room = room_fixture()
      assert Rooms.list_rooms() == [room]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Rooms.get_room!(room.id) == room
    end

    test "get_room!/2 returns the room with associations loaded" do
      room = room_fixture()

      {:ok, message} =
        Messages.publish_message_to_room(room, MessagesFixtures.valid_message_attrs())

      assert Rooms.get_room!(room.id, preload: [:messages]).messages == [message]
    end

    test "create_room/1 with valid data creates a room" do
      valid_attrs = %{
        created_by: "some created_by",
        description: "some description",
        name: "some name"
      }

      assert {:ok, %Room{} = room} = Rooms.create_room(valid_attrs)
      assert room.created_by == "some created_by"
      assert room.description == "some description"
      assert room.name == "some name"
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rooms.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()

      update_attrs = %{
        created_by: "some updated created_by",
        description: "some updated description",
        name: "some updated name"
      }

      assert {:ok, %Room{} = room} = Rooms.update_room(room, update_attrs)
      assert room.created_by == "some updated created_by"
      assert room.description == "some updated description"
      assert room.name == "some updated name"
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = room_fixture()
      assert {:error, %Ecto.Changeset{}} = Rooms.update_room(room, @invalid_attrs)
      assert room == Rooms.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Rooms.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Rooms.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = Rooms.change_room(room)
    end
  end
end
