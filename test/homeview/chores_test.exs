defmodule Homeview.ChoresTest do
  use Homeview.DataCase

  alias Homeview.Chores

  describe "chores" do
    alias Homeview.Chores.Chore

    import Homeview.ChoresFixtures

    @invalid_attrs %{iconUrl: nil, name: nil, time_interval: nil}

    test "list_chores/0 returns all chores" do
      chore = chore_fixture()
      assert Chores.list_chores() == [chore]
    end

    test "get_chore!/1 returns the chore with given id" do
      chore = chore_fixture()
      assert Chores.get_chore!(chore.id) == chore
    end

    test "create_chore/1 with valid data creates a chore" do
      valid_attrs = %{iconUrl: "some iconUrl", name: "some name", time_interval: 42}

      assert {:ok, %Chore{} = chore} = Chores.create_chore(valid_attrs)
      assert chore.iconUrl == "some iconUrl"
      assert chore.name == "some name"
      assert chore.time_interval == 42
    end

    test "create_chore/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chores.create_chore(@invalid_attrs)
    end

    test "update_chore/2 with valid data updates the chore" do
      chore = chore_fixture()
      update_attrs = %{iconUrl: "some updated iconUrl", name: "some updated name", time_interval: 43}

      assert {:ok, %Chore{} = chore} = Chores.update_chore(chore, update_attrs)
      assert chore.iconUrl == "some updated iconUrl"
      assert chore.name == "some updated name"
      assert chore.time_interval == 43
    end

    test "update_chore/2 with invalid data returns error changeset" do
      chore = chore_fixture()
      assert {:error, %Ecto.Changeset{}} = Chores.update_chore(chore, @invalid_attrs)
      assert chore == Chores.get_chore!(chore.id)
    end

    test "delete_chore/1 deletes the chore" do
      chore = chore_fixture()
      assert {:ok, %Chore{}} = Chores.delete_chore(chore)
      assert_raise Ecto.NoResultsError, fn -> Chores.get_chore!(chore.id) end
    end

    test "change_chore/1 returns a chore changeset" do
      chore = chore_fixture()
      assert %Ecto.Changeset{} = Chores.change_chore(chore)
    end
  end

  describe "chore_histories" do
    alias Homeview.Chores.ChoreHistory

    import Homeview.ChoresFixtures

    @invalid_attrs %{completed_date: nil}

    test "list_chore_histories/0 returns all chore_histories" do
      chore_history = chore_history_fixture()
      assert Chores.list_chore_histories() == [chore_history]
    end

    test "get_chore_history!/1 returns the chore_history with given id" do
      chore_history = chore_history_fixture()
      assert Chores.get_chore_history!(chore_history.id) == chore_history
    end

    test "create_chore_history/1 with valid data creates a chore_history" do
      valid_attrs = %{completed_date: ~D[2023-05-18]}

      assert {:ok, %ChoreHistory{} = chore_history} = Chores.create_chore_history(valid_attrs)
      assert chore_history.completed_date == ~D[2023-05-18]
    end

    test "create_chore_history/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chores.create_chore_history(@invalid_attrs)
    end

    test "update_chore_history/2 with valid data updates the chore_history" do
      chore_history = chore_history_fixture()
      update_attrs = %{completed_date: ~D[2023-05-19]}

      assert {:ok, %ChoreHistory{} = chore_history} = Chores.update_chore_history(chore_history, update_attrs)
      assert chore_history.completed_date == ~D[2023-05-19]
    end

    test "update_chore_history/2 with invalid data returns error changeset" do
      chore_history = chore_history_fixture()
      assert {:error, %Ecto.Changeset{}} = Chores.update_chore_history(chore_history, @invalid_attrs)
      assert chore_history == Chores.get_chore_history!(chore_history.id)
    end

    test "delete_chore_history/1 deletes the chore_history" do
      chore_history = chore_history_fixture()
      assert {:ok, %ChoreHistory{}} = Chores.delete_chore_history(chore_history)
      assert_raise Ecto.NoResultsError, fn -> Chores.get_chore_history!(chore_history.id) end
    end

    test "change_chore_history/1 returns a chore_history changeset" do
      chore_history = chore_history_fixture()
      assert %Ecto.Changeset{} = Chores.change_chore_history(chore_history)
    end
  end
end
