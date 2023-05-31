defmodule Homeview.Groceries do
  @moduledoc """
  The Groceries context.
  """

  import Ecto.Query, warn: false
  alias Homeview.Repo

  alias Homeview.Groceries.Grocery

  @pubsub Homeview.PubSub
  @topic inspect(__MODULE__)

  def subscribe() do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  def broadcast(grocery, tag) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {tag, grocery})
    grocery
  end

  @doc """
  Returns the list of groceries.

  ## Examples

      iex> list_groceries()
      [%Grocery{}, ...]

  """
  def list_groceries do
    query =
      Ecto.Query.from(g in Grocery,
        where:
          is_nil(g.bought) or
            (not is_nil(g.bought) and
               g.updated_at > datetime_add(^NaiveDateTime.utc_now(), -2, "hour")),
        order_by: [desc: g.updated_at]
      )

    Repo.all(query)
  end

  @doc """
  Gets a single grocery.

  Raises `Ecto.NoResultsError` if the Grocery does not exist.

  ## Examples

      iex> get_grocery!(123)
      %Grocery{}

      iex> get_grocery!(456)
      ** (Ecto.NoResultsError)

  """
  def get_grocery!(id), do: Repo.get!(Grocery, id)

  @doc """
  Creates a grocery.

  ## Examples

      iex> create_grocery(%{field: value})
      {:ok, %Grocery{}}

      iex> create_grocery(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_grocery(attrs \\ %{}) do
    case %Grocery{}
         |> Grocery.changeset(attrs)
         |> Repo.insert() do
      {:ok, grocery} -> {:ok, broadcast(grocery, :create_grocery)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates a grocery.

  ## Examples

      iex> update_grocery(grocery, %{field: new_value})
      {:ok, %Grocery{}}

      iex> update_grocery(grocery, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_grocery(%Grocery{} = grocery, attrs) do
    {:ok, new} =
      grocery
      |> Grocery.changeset(attrs)
      |> Repo.update()

    broadcast(new, :update_grocery)
  end

  def increment_grocery(%Grocery{} = grocery) do
    {:ok, new} =
      grocery
      |> Grocery.changeset(%{amount: grocery.amount + 1})
      |> Repo.update()

    broadcast(new, :update_grocery)
  end

  def decrement_grocery(%Grocery{} = grocery) do
    {:ok, new} =
      grocery
      |> Grocery.changeset(%{amount: grocery.amount - 1})
      |> Repo.update()

    broadcast(new, :update_grocery)
  end

  def buy_grocery(%Grocery{} = grocery) do
    {:ok, new} =
      grocery
      |> Grocery.changeset(%{bought: NaiveDateTime.utc_now()})
      |> Repo.update()

    broadcast(new, :buy_grocery)
  end

  def unbuy_grocery(%Grocery{} = grocery) do
    {:ok, new} =
      grocery
      |> Grocery.changeset(%{bought: nil})
      |> Repo.update()

    broadcast(new, :unbuy_grocery)
  end

  @doc """
  Deletes a grocery.

  ## Examples

      iex> delete_grocery(grocery)
      {:ok, %Grocery{}}

      iex> delete_grocery(grocery)
      {:error, %Ecto.Changeset{}}

  """
  def delete_grocery(%Grocery{} = grocery) do
    Repo.delete(grocery)
    broadcast(grocery, :delete_grocery)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking grocery changes.

  ## Examples

      iex> change_grocery(grocery)
      %Ecto.Changeset{data: %Grocery{}}

  """
  def change_grocery(%Grocery{} = grocery, attrs \\ %{}) do
    Grocery.changeset(grocery, attrs)
  end
end
