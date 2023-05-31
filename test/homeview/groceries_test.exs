defmodule Homeview.GroceriesTest do
  use Homeview.DataCase

  alias Homeview.Groceries

  describe "groceries" do
    alias Homeview.Groceries.Grocery

    import Homeview.GroceriesFixtures

    @invalid_attrs %{amount: nil, bought: nil, name: nil, unit: nil}

    test "list_groceries/0 returns all groceries" do
      grocery = grocery_fixture()
      assert Groceries.list_groceries() == [grocery]
    end

    test "get_grocery!/1 returns the grocery with given id" do
      grocery = grocery_fixture()
      assert Groceries.get_grocery!(grocery.id) == grocery
    end

    test "create_grocery/1 with valid data creates a grocery" do
      valid_attrs = %{amount: 42, bought: ~T[14:00:00], name: "some name", unit: "some unit"}

      assert {:ok, %Grocery{} = grocery} = Groceries.create_grocery(valid_attrs)
      assert grocery.amount == 42
      assert grocery.bought == ~T[14:00:00]
      assert grocery.name == "some name"
      assert grocery.unit == "some unit"
    end

    test "create_grocery/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groceries.create_grocery(@invalid_attrs)
    end

    test "update_grocery/2 with valid data updates the grocery" do
      grocery = grocery_fixture()
      update_attrs = %{amount: 43, bought: ~T[15:01:01], name: "some updated name", unit: "some updated unit"}

      assert {:ok, %Grocery{} = grocery} = Groceries.update_grocery(grocery, update_attrs)
      assert grocery.amount == 43
      assert grocery.bought == ~T[15:01:01]
      assert grocery.name == "some updated name"
      assert grocery.unit == "some updated unit"
    end

    test "update_grocery/2 with invalid data returns error changeset" do
      grocery = grocery_fixture()
      assert {:error, %Ecto.Changeset{}} = Groceries.update_grocery(grocery, @invalid_attrs)
      assert grocery == Groceries.get_grocery!(grocery.id)
    end

    test "delete_grocery/1 deletes the grocery" do
      grocery = grocery_fixture()
      assert {:ok, %Grocery{}} = Groceries.delete_grocery(grocery)
      assert_raise Ecto.NoResultsError, fn -> Groceries.get_grocery!(grocery.id) end
    end

    test "change_grocery/1 returns a grocery changeset" do
      grocery = grocery_fixture()
      assert %Ecto.Changeset{} = Groceries.change_grocery(grocery)
    end
  end
end
