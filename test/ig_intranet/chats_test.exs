defmodule IgIntranet.ChatsTest do
  use IgIntranet.DataCase

  alias IgIntranet.Chats

  describe "intranet_conversations" do
    alias IgIntranet.Chats.IntranetConversation

    import IgIntranet.ChatsFixtures

    @invalid_attrs %{conversation_type: nil, conversation_status: nil}

    test "list_intranet_conversations/0 returns all intranet_conversations" do
      intranet_conversation = intranet_conversation_fixture()
      assert Chats.list_intranet_conversations() == [intranet_conversation]
    end

    test "get_intranet_conversation!/1 returns the intranet_conversation with given id" do
      intranet_conversation = intranet_conversation_fixture()
      assert Chats.get_intranet_conversation!(intranet_conversation.id) == intranet_conversation
    end

    test "create_intranet_conversation/1 with valid data creates a intranet_conversation" do
      valid_attrs = %{
        conversation_type: "public",
        conversation_status: "active"
      }

      assert {:ok, %IntranetConversation{} = intranet_conversation} =
               Chats.create_intranet_conversation(valid_attrs)

      assert intranet_conversation.conversation_type == :public
      assert intranet_conversation.conversation_status == :active
    end

    test "create_intranet_conversation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_intranet_conversation(@invalid_attrs)
    end

    test "update_intranet_conversation/2 with valid data updates the intranet_conversation" do
      intranet_conversation = intranet_conversation_fixture()

      update_attrs = %{
        conversation_type: "private",
        conversation_status: "archived"
      }

      assert {:ok, %IntranetConversation{} = intranet_conversation} =
               Chats.update_intranet_conversation(intranet_conversation, update_attrs)

      assert intranet_conversation.conversation_type == :private
      assert intranet_conversation.conversation_status == :archived
    end

    test "update_intranet_conversation/2 with invalid data returns error changeset" do
      intranet_conversation = intranet_conversation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Chats.update_intranet_conversation(intranet_conversation, @invalid_attrs)

      assert intranet_conversation == Chats.get_intranet_conversation!(intranet_conversation.id)
    end

    test "delete_intranet_conversation/1 deletes the intranet_conversation" do
      intranet_conversation = intranet_conversation_fixture()

      assert {:ok, %IntranetConversation{}} =
               Chats.delete_intranet_conversation(intranet_conversation)

      assert_raise Ecto.NoResultsError, fn ->
        Chats.get_intranet_conversation!(intranet_conversation.id)
      end
    end

    test "change_intranet_conversation/1 returns a intranet_conversation changeset" do
      intranet_conversation = intranet_conversation_fixture()
      assert %Ecto.Changeset{} = Chats.change_intranet_conversation(intranet_conversation)
    end
  end

  describe "intranet_messages" do
    alias IgIntranet.Chats.IntranetMessage

    import IgIntranet.ChatsFixtures

    @invalid_attrs %{message_body: nil}

    defp create_intranet_conversation(_) do
      intranet_conversation =
        intranet_conversation_fixture()

      %{intranet_conversation: intranet_conversation}
    end

    setup [:create_intranet_conversation]

    test "list_intranet_messages/0 returns all intranet_messages", %{
      intranet_conversation: intranet_conversation
    } do
      intranet_message =
        intranet_message_fixture(intranet_conversation_id: intranet_conversation.id)

      assert Chats.list_intranet_messages() == [intranet_message]
    end

    test "get_intranet_message!/1 returns the intranet_message with given id", %{
      intranet_conversation: intranet_conversation
    } do
      intranet_message =
        intranet_message_fixture(intranet_conversation_id: intranet_conversation.id)

      assert Chats.get_intranet_message!(intranet_message.id) == intranet_message
    end

    test "create_intranet_message/1 with valid data creates a intranet_message", %{
      intranet_conversation: intranet_conversation
    } do
      valid_attrs = %{
        message_body: "some message_body",
        intranet_conversation_id: intranet_conversation.id
      }

      assert {:ok, %IntranetMessage{} = intranet_message} =
               Chats.create_intranet_message(valid_attrs)

      assert intranet_message.message_body == "some message_body"
    end

    test "create_intranet_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_intranet_message(@invalid_attrs)
    end

    test "update_intranet_message/2 with valid data updates the intranet_message", %{
      intranet_conversation: intranet_conversation
    } do
      intranet_message =
        intranet_message_fixture(intranet_conversation_id: intranet_conversation.id)

      update_attrs = %{message_body: "some updated message_body"}

      assert {:ok, %IntranetMessage{} = intranet_message} =
               Chats.update_intranet_message(intranet_message, update_attrs)

      assert intranet_message.message_body == "some updated message_body"
    end

    test "update_intranet_message/2 with invalid data returns error changeset", %{
      intranet_conversation: intranet_conversation
    } do
      intranet_message =
        intranet_message_fixture(intranet_conversation_id: intranet_conversation.id)

      assert {:error, %Ecto.Changeset{}} =
               Chats.update_intranet_message(intranet_message, @invalid_attrs)

      assert intranet_message == Chats.get_intranet_message!(intranet_message.id)
    end

    test "delete_intranet_message/1 deletes the intranet_message", %{
      intranet_conversation: intranet_conversation
    } do
      intranet_message =
        intranet_message_fixture(intranet_conversation_id: intranet_conversation.id)

      assert {:ok, %IntranetMessage{}} = Chats.delete_intranet_message(intranet_message)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_intranet_message!(intranet_message.id) end
    end

    test "change_intranet_message/1 returns a intranet_message changeset", %{
      intranet_conversation: intranet_conversation
    } do
      intranet_message =
        intranet_message_fixture(intranet_conversation_id: intranet_conversation.id)

      assert %Ecto.Changeset{} = Chats.change_intranet_message(intranet_message)
    end
  end
end
