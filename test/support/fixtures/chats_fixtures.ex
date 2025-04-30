defmodule IgIntranet.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `IgIntranet.Chats` context.
  """

  @doc """
  Generate a intranet_conversation.
  """
  def intranet_conversation_fixture(attrs \\ %{}) do
    {:ok, intranet_conversation} =
      attrs
      |> Enum.into(%{
        conversation_type: "public",
        conversation_status: "active"
      })
      |> IgIntranet.Chats.create_intranet_conversation()

    intranet_conversation
  end

  @doc """
  Generate a intranet_message.
  """
  def intranet_message_fixture(attrs \\ %{}) do
    intranet_conversation_id =
      attrs[:intranet_conversation_id] ||
        intranet_conversation_fixture(attrs[:intranet_conversation] || %{}).id

    {:ok, intranet_message} =
      attrs
      |> Enum.into(%{
        intranet_conversation_id: intranet_conversation_id,
        message_body: "some message_body"
      })
      |> IgIntranet.Chats.create_intranet_message()

    intranet_message
  end
end
