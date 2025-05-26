defmodule IgIntranetWeb.IntranetConversationLiveTest do
  use IgIntranetWeb.ConnCase

  import Phoenix.LiveViewTest
  import IgIntranet.ChatsFixtures

  @create_attrs %{
    conversation_type: "public",
    conversation_status: "active",
    conversation_topic: "some other conversation_topic"
  }
  @update_attrs %{
    conversation_type: "private",
    conversation_status: "archived",
    conversation_topic: "some updated conversation_topic"
  }
  @invalid_attrs %{conversation_type: nil, conversation_status: nil, conversation_topic: nil}

  defp create_intranet_conversation(_) do
    intranet_conversation = intranet_conversation_fixture()
    %{intranet_conversation: intranet_conversation}
  end

  describe "Index" do
    setup [:create_intranet_conversation]

    test "lists all intranet_conversations", %{
      conn: conn,
      intranet_conversation: _intranet_conversation
    } do
      {:ok, _index_live, html} = live(conn, ~p"/intranet_conversations")

      assert html =~ "Listing Intranet conversations"
      assert html =~ "public"
      assert html =~ "active"
    end

    test "saves new intranet_conversation", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/intranet_conversations")

      assert index_live |> element("a", "New Intranet conversation") |> render_click() =~
               "New Intranet conversation"

      assert_patch(index_live, ~p"/intranet_conversations/new")

      assert index_live
             |> form("#intranet_conversation-form", intranet_conversation: @invalid_attrs)
             |> render_change()

      assert index_live
             |> form("#intranet_conversation-form", intranet_conversation: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/intranet_conversations")

      html = render(index_live)
      assert html =~ "Intranet conversation created successfully"
      assert html =~ "public"
      assert html =~ "active"
    end

    test "updates intranet_conversation in listing", %{
      conn: conn,
      intranet_conversation: intranet_conversation
    } do
      {:ok, index_live, _html} = live(conn, ~p"/intranet_conversations")

      assert index_live
             |> element("#intranet_conversations-#{intranet_conversation.id} a", "Edit")
             |> render_click() =~
               "Edit Intranet conversation"

      assert_patch(index_live, ~p"/intranet_conversations/#{intranet_conversation}/edit")

      assert index_live
             |> form("#intranet_conversation-form", intranet_conversation: @invalid_attrs)
             |> render_change()

      assert index_live
             |> form("#intranet_conversation-form", intranet_conversation: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/intranet_conversations")

      html = render(index_live)
      assert html =~ "Intranet conversation updated successfully"
      assert html =~ "private"
      assert html =~ "archived"
    end

    test "deletes intranet_conversation in listing", %{
      conn: conn,
      intranet_conversation: intranet_conversation
    } do
      {:ok, index_live, _html} = live(conn, ~p"/intranet_conversations")

      assert index_live
             |> element("#intranet_conversations-#{intranet_conversation.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#intranet_conversations-#{intranet_conversation.id}")
    end
  end

  describe "Show" do
    setup [:create_intranet_conversation]

    test "displays intranet_conversation", %{
      conn: conn,
      intranet_conversation: intranet_conversation
    } do
      {:ok, _show_live, html} = live(conn, ~p"/intranet_conversations/#{intranet_conversation}")

      assert html =~ "Show Intranet conversation"
      assert html =~ "public"
      assert html =~ "active"
    end

    test "updates intranet_conversation within modal", %{
      conn: conn,
      intranet_conversation: intranet_conversation
    } do
      {:ok, show_live, _html} = live(conn, ~p"/intranet_conversations/#{intranet_conversation}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Intranet conversation"

      assert_patch(show_live, ~p"/intranet_conversations/#{intranet_conversation}/show/edit")

      assert show_live
             |> form("#intranet_conversation-form", intranet_conversation: @invalid_attrs)
             |> render_change()

      assert show_live
             |> form("#intranet_conversation-form", intranet_conversation: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/intranet_conversations/#{intranet_conversation}")

      html = render(show_live)
      assert html =~ "Intranet conversation updated successfully"
      assert html =~ "private"
      assert html =~ "archived"
    end
  end
end
