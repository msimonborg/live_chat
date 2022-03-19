defmodule LiveChat.MessagesTest do
  use LiveChat.DataCase

  alias LiveChat.Messages

  describe "messages" do
    import LiveChat.MessagesFixtures

    alias LiveChat.Messages.Message
    alias LiveChat.RoomsFixtures

    @valid_attrs valid_message_attrs()
    @update_attrs update_message_attrs()
    @invalid_attrs invalid_message_attrs()

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Messages.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Messages.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      assert {:ok, %Message{} = message} = Messages.create_message(@valid_attrs)
      assert message.body == "some body"
      assert message.created_by == "some created_by"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messages.create_message(@invalid_attrs)
    end

    test "create_message/1 with a room_id associates the message to the room" do
      room = RoomsFixtures.room_fixture()

      assert {:ok, %Message{} = message} =
               Messages.create_message(Map.merge(@valid_attrs, %{room_id: room.id}))

      assert message.room_id == room.id
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      assert {:ok, %Message{} = message} = Messages.update_message(message, @update_attrs)
      assert message.body == "some updated body"
      assert message.created_by == "some updated created_by"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Messages.update_message(message, @invalid_attrs)
      assert message == Messages.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Messages.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Messages.change_message(message)
    end

    test "publish_message_to_room/2 publishes a new message to the room" do
      room = RoomsFixtures.room_fixture()
      assert {:ok, %Message{} = message} = Messages.publish_message_to_room(room, @valid_attrs)
      assert message.room_id == room.id
    end

    test "publish_message_to_room/2 returns error changeset with invalid message data" do
      room = RoomsFixtures.room_fixture()
      assert {:error, %Ecto.Changeset{}} = Messages.publish_message_to_room(room, @invalid_attrs)
    end
  end
end
