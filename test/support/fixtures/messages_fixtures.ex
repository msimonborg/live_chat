defmodule LiveChat.MessagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LiveChat.Messages` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(valid_message_attrs())
      |> LiveChat.Messages.create_message()

    message
  end

  def valid_message_attrs do
    %{body: "some body", created_by: "some created_by"}
  end

  def update_message_attrs do
    %{body: "some updated body", created_by: "some updated created_by"}
  end

  def invalid_message_attrs do
    %{body: nil, created_by: nil}
  end
end
