defmodule Homeview.PollsTest do
  use Homeview.DataCase

  alias Homeview.Polls

  describe "polls" do
    alias Homeview.Polls.Poll

    import Homeview.PollsFixtures

    @invalid_attrs %{text: nil, ready_to_vote: nil, created_by: nil}

    test "list_polls/0 returns all polls" do
      poll = poll_fixture()
      assert Polls.list_polls() == [poll]
    end

    test "get_poll!/1 returns the poll with given id" do
      poll = poll_fixture()
      assert Polls.get_poll!(poll.id) == poll
    end

    test "create_poll/1 with valid data creates a poll" do
      valid_attrs = %{text: "some text", ready_to_vote: true, created_by: "some created_by"}

      assert {:ok, %Poll{} = poll} = Polls.create_poll(valid_attrs)
      assert poll.text == "some text"
      assert poll.ready_to_vote == true
      assert poll.created_by == "some created_by"
    end

    test "create_poll/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Polls.create_poll(@invalid_attrs)
    end

    test "update_poll/2 with valid data updates the poll" do
      poll = poll_fixture()
      update_attrs = %{text: "some updated text", ready_to_vote: false, created_by: "some updated created_by"}

      assert {:ok, %Poll{} = poll} = Polls.update_poll(poll, update_attrs)
      assert poll.text == "some updated text"
      assert poll.ready_to_vote == false
      assert poll.created_by == "some updated created_by"
    end

    test "update_poll/2 with invalid data returns error changeset" do
      poll = poll_fixture()
      assert {:error, %Ecto.Changeset{}} = Polls.update_poll(poll, @invalid_attrs)
      assert poll == Polls.get_poll!(poll.id)
    end

    test "delete_poll/1 deletes the poll" do
      poll = poll_fixture()
      assert {:ok, %Poll{}} = Polls.delete_poll(poll)
      assert_raise Ecto.NoResultsError, fn -> Polls.get_poll!(poll.id) end
    end

    test "change_poll/1 returns a poll changeset" do
      poll = poll_fixture()
      assert %Ecto.Changeset{} = Polls.change_poll(poll)
    end
  end
end
