defmodule HomeviewWeb.ChoreLiveTest do
  use HomeviewWeb.ConnCase

  import Phoenix.LiveViewTest
  import Homeview.ChoresFixtures

  @create_attrs %{iconUrl: "some iconUrl", name: "some name", time_interval: 42}
  @update_attrs %{iconUrl: "some updated iconUrl", name: "some updated name", time_interval: 43}
  @invalid_attrs %{iconUrl: nil, name: nil, time_interval: nil}

  defp create_chore(_) do
    chore = chore_fixture()
    %{chore: chore}
  end

  describe "Index" do
    setup [:create_chore]

    test "lists all chores", %{conn: conn, chore: chore} do
      {:ok, _index_live, html} = live(conn, ~p"/chores")

      assert html =~ "Listing Chores"
      assert html =~ chore.iconUrl
    end

    test "saves new chore", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/chores")

      assert index_live |> element("a", "New Chore") |> render_click() =~
               "New Chore"

      assert_patch(index_live, ~p"/chores/new")

      assert index_live
             |> form("#chore-form", chore: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#chore-form", chore: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/chores")

      html = render(index_live)
      assert html =~ "Chore created successfully"
      assert html =~ "some iconUrl"
    end

    test "updates chore in listing", %{conn: conn, chore: chore} do
      {:ok, index_live, _html} = live(conn, ~p"/chores")

      assert index_live |> element("#chores-#{chore.id} a", "Edit") |> render_click() =~
               "Edit Chore"

      assert_patch(index_live, ~p"/chores/#{chore}/edit")

      assert index_live
             |> form("#chore-form", chore: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#chore-form", chore: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/chores")

      html = render(index_live)
      assert html =~ "Chore updated successfully"
      assert html =~ "some updated iconUrl"
    end

    test "deletes chore in listing", %{conn: conn, chore: chore} do
      {:ok, index_live, _html} = live(conn, ~p"/chores")

      assert index_live |> element("#chores-#{chore.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#chores-#{chore.id}")
    end
  end

  describe "Show" do
    setup [:create_chore]

    test "displays chore", %{conn: conn, chore: chore} do
      {:ok, _show_live, html} = live(conn, ~p"/chores/#{chore}")

      assert html =~ "Show Chore"
      assert html =~ chore.iconUrl
    end

    test "updates chore within modal", %{conn: conn, chore: chore} do
      {:ok, show_live, _html} = live(conn, ~p"/chores/#{chore}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Chore"

      assert_patch(show_live, ~p"/chores/#{chore}/show/edit")

      assert show_live
             |> form("#chore-form", chore: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#chore-form", chore: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/chores/#{chore}")

      html = render(show_live)
      assert html =~ "Chore updated successfully"
      assert html =~ "some updated iconUrl"
    end
  end
end
