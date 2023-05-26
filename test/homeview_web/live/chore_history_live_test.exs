defmodule HomeviewWeb.ChoreHistoryLiveTest do
  use HomeviewWeb.ConnCase

  import Phoenix.LiveViewTest
  import Homeview.ChoresFixtures

  @create_attrs %{completed_date: "2023-05-18"}
  @update_attrs %{completed_date: "2023-05-19"}
  @invalid_attrs %{completed_date: nil}

  defp create_chore_history(_) do
    chore_history = chore_history_fixture()
    %{chore_history: chore_history}
  end

  describe "Index" do
    setup [:create_chore_history]

    test "lists all chore_histories", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/chore_histories")

      assert html =~ "Listing Chore histories"
    end

    test "saves new chore_history", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/chore_histories")

      assert index_live |> element("a", "New Chore history") |> render_click() =~
               "New Chore history"

      assert_patch(index_live, ~p"/chore_histories/new")

      assert index_live
             |> form("#chore_history-form", chore_history: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#chore_history-form", chore_history: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/chore_histories")

      html = render(index_live)
      assert html =~ "Chore history created successfully"
    end

    test "updates chore_history in listing", %{conn: conn, chore_history: chore_history} do
      {:ok, index_live, _html} = live(conn, ~p"/chore_histories")

      assert index_live |> element("#chore_histories-#{chore_history.id} a", "Edit") |> render_click() =~
               "Edit Chore history"

      assert_patch(index_live, ~p"/chore_histories/#{chore_history}/edit")

      assert index_live
             |> form("#chore_history-form", chore_history: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#chore_history-form", chore_history: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/chore_histories")

      html = render(index_live)
      assert html =~ "Chore history updated successfully"
    end

    test "deletes chore_history in listing", %{conn: conn, chore_history: chore_history} do
      {:ok, index_live, _html} = live(conn, ~p"/chore_histories")

      assert index_live |> element("#chore_histories-#{chore_history.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#chore_histories-#{chore_history.id}")
    end
  end

  describe "Show" do
    setup [:create_chore_history]

    test "displays chore_history", %{conn: conn, chore_history: chore_history} do
      {:ok, _show_live, html} = live(conn, ~p"/chore_histories/#{chore_history}")

      assert html =~ "Show Chore history"
    end

    test "updates chore_history within modal", %{conn: conn, chore_history: chore_history} do
      {:ok, show_live, _html} = live(conn, ~p"/chore_histories/#{chore_history}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Chore history"

      assert_patch(show_live, ~p"/chore_histories/#{chore_history}/show/edit")

      assert show_live
             |> form("#chore_history-form", chore_history: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#chore_history-form", chore_history: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/chore_histories/#{chore_history}")

      html = render(show_live)
      assert html =~ "Chore history updated successfully"
    end
  end
end
