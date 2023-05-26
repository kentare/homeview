defmodule Homeview.ChoresFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Homeview.Chores` context.
  """

  @doc """
  Generate a chore.
  """
  def chore_fixture(attrs \\ %{}) do
    {:ok, chore} =
      attrs
      |> Enum.into(%{
        iconUrl: "some iconUrl",
        name: "some name",
        time_interval: 42
      })
      |> Homeview.Chores.create_chore()

    chore
  end

  @doc """
  Generate a chore_history.
  """
  def chore_history_fixture(attrs \\ %{}) do
    {:ok, chore_history} =
      attrs
      |> Enum.into(%{
        completed_date: ~D[2023-05-18]
      })
      |> Homeview.Chores.create_chore_history()

    chore_history
  end
end
