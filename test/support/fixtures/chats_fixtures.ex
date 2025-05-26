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
        conversation_status: "active",
        conversation_topic: "some conversation_topic"
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

    user_id =
      attrs[:user_id] || IgIntranet.AccountsFixtures.user_fixture(attrs[:user] || %{}).id

    {:ok, intranet_message} =
      attrs
      |> Enum.into(%{
        intranet_conversation_id: intranet_conversation_id,
        message_body: "some message_body",
        user_id: user_id
      })
      |> IgIntranet.Chats.create_intranet_message()

    intranet_message
  end

  @doc """
  Generate a intranet_message with preload on conversation.
  """
  def intranet_message_fixture_with_conversation_preloaded(attrs \\ %{}) do
    intranet_conversation_id =
      attrs[:intranet_conversation_id] ||
        intranet_conversation_fixture(attrs[:intranet_conversation] || %{}).id

    user_id =
      attrs[:user_id] || IgIntranet.AccountsFixtures.user_fixture(attrs[:user] || %{}).id

    {:ok, intranet_message} =
      attrs
      |> Enum.into(%{
        intranet_conversation_id: intranet_conversation_id,
        user_id: user_id,
        message_body: "some message_body"
      })
      |> IgIntranet.Chats.create_intranet_message_with_preload()

    intranet_message
  end
end
