defmodule Homeview.PollsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Homeview.Polls` context.
  """

  @doc """
  Generate a poll.
  """
  def poll_fixture(attrs \\ %{}) do
    {:ok, poll} =
      attrs
      |> Enum.into(%{
        text: "some text",
        ready_to_vote: true,
        created_by: "some created_by"
      })
      |> Homeview.Polls.create_poll()

    poll
  end
end
