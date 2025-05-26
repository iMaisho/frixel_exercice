defmodule IgIntranetWeb.IntranetMessageLiveTest do
  use IgIntranetWeb.ConnCase

  import Phoenix.LiveViewTest
  import IgIntranet.ChatsFixtures

  @invalid_attrs %{message_body: nil, intranet_conversation_id: nil, user_id: nil}

  defp create_intranet_message(_) do
    intranet_message = intranet_message_fixture_with_conversation_preloaded()
    %{intranet_message: intranet_message}
  end

  describe "Index" do
    setup [:authenticate_user_and_create_intranet_message]

    test "lists all intranet_messages", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/intranet_messages")

      assert html =~ "Listing Intranet messages"
      assert html =~ "some message_body"
    end

    test "saves new intranet_message", %{conn: conn, user: user_registered} do
      create_attrs = %{
        message_body: "some another message_body",
        intranet_conversation_id:
          intranet_conversation_fixture(%{conversation_topic: "another conversation_topic"}).id,
        user_id: user_registered.id
      }

      {:ok, index_live, _html} = live(conn, ~p"/intranet_messages")

      assert index_live |> element("a", "New Intranet message") |> render_click() =~
               "New Intranet message"

      assert_patch(index_live, ~p"/intranet_messages/new")

      assert index_live
             |> form("#intranet_message-form", intranet_message: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#intranet_message-form", intranet_message: create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/intranet_messages")

      html = render(index_live)
      assert html =~ "Intranet message created successfully"
      assert html =~ "some another message_body"
    end

    test "updates intranet_message in listing", %{
      conn: conn,
      intranet_message: intranet_message
    } do
      update_attrs =
        %{
          message_body: "some updated message_body",
          intranet_conversation_id: intranet_message.intranet_conversation.id,
          user_id: intranet_message.user_id
        }

      {:ok, index_live, _html} = live(conn, ~p"/intranet_messages")

      assert index_live
             |> element("#intranet_messages-#{intranet_message.id} a", "Edit")
             |> render_click() =~
               "Edit Intranet message"

      assert_patch(index_live, ~p"/intranet_messages/#{intranet_message}/edit")

      assert index_live
             |> form("#intranet_message-form", intranet_message: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#intranet_message-form", intranet_message: update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/intranet_messages")

      html = render(index_live)
      assert html =~ "Intranet message updated successfully"
      assert html =~ "some updated message_body"
    end

    test "deletes intranet_message in listing", %{conn: conn, intranet_message: intranet_message} do
      {:ok, index_live, _html} = live(conn, ~p"/intranet_messages")

      assert index_live
             |> element("#intranet_messages-#{intranet_message.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#intranet_messages-#{intranet_message.id}")
    end
  end

  describe "Show" do
    setup [:create_intranet_message, :register_and_log_in_user]

    test "displays intranet_message", %{conn: conn, intranet_message: intranet_message} do
      {:ok, _show_live, html} = live(conn, ~p"/intranet_messages/#{intranet_message}")

      assert html =~ "Show Intranet message"
      assert html =~ intranet_message.message_body
    end

    test "updates intranet_message within modal", %{
      conn: conn,
      intranet_message: intranet_message,
      user: user_registered
    } do
      update_attrs = %{
        message_body: "some updated message_body",
        intranet_conversation_id: intranet_message.intranet_conversation.id,
        user_id: user_registered.id
      }

      {:ok, show_live, _html} = live(conn, ~p"/intranet_messages/#{intranet_message}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Intranet message"

      assert_patch(show_live, ~p"/intranet_messages/#{intranet_message}/show/edit")

      assert show_live
             |> form("#intranet_message-form", intranet_message: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#intranet_message-form", intranet_message: update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/intranet_messages/#{intranet_message}")

      html = render(show_live)
      assert html =~ "Intranet message updated successfully"
      assert html =~ "some updated message_body"
    end
  end
end
