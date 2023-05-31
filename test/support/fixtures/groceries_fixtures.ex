defmodule Homeview.GroceriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Homeview.Groceries` context.
  """

  @doc """
  Generate a grocery.
  """
  def grocery_fixture(attrs \\ %{}) do
    {:ok, grocery} =
      attrs
      |> Enum.into(%{
        amount: 42,
        bought: ~T[14:00:00],
        name: "some name",
        unit: "some unit"
      })
      |> Homeview.Groceries.create_grocery()

    grocery
  end
end
