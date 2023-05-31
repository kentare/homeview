defmodule Homeview.Chores do
  @moduledoc """
  The Chores context.
  """

  import Ecto.Query, warn: false
  alias Homeview.Repo

  alias Homeview.Chores.Chore

  @topic inspect(__MODULE__)
  @pubsub Homeview.PubSub

  @doc """
  Returns the list of chores.

  ## Examples

      iex> list_chores()
      [%Chore{}, ...]

  """

  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  def broadcast(chore, tag) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {tag, chore})
    chore
  end

  def broadcast_update(%{:id => id}) do
    get_chore!(id) |> broadcast(:update_chore)
  end

  def list_chores do
    query =
      from(c in Chore,
        preload: [:chore_histories]
      )

    all = Repo.all(query)

    all = sort_chores_by_lowest_diff_of_time_interval_from_newest_chore_history(all)

    all
  end

  defp sort_chores_by_lowest_diff_of_time_interval_from_newest_chore_history(chores) do
    chores
    |> Enum.map(fn chore -> return_newest_chore_history(chore) end)
    |> Enum.sort(fn a, b ->
      cond do
        a.chore_histories == nil ->
          true

        b.chore_histories == nil ->
          false

        true ->
          a.fill_percent > b.fill_percent
      end
    end)
  end

  defp days_till_next_chore(chore) do
    cond do
      chore.chore_histories == nil ->
        0

      true ->
        chore.time_interval + Timex.diff(chore.chore_histories.completed_date, Timex.now(), :days)
    end
  end

  defp weights(chore) do
    days_left = days_till_next_chore(chore)

    cond do
      chore.time_interval - days_left == 0 ->
        100

      days_left == 0 ->
        0.0

      days_left > 5 && chore.time_interval > 7 ->
        days_left / chore.time_interval * 1.5

      days_left < 5 ->
        days_left / chore.time_interval * 0.8

      true ->
        days_left / chore.time_interval * 1
    end
  end

  defp fill_percent_for_chore(chore) do
    cond do
      chore.chore_histories == nil ->
        100

      true ->
        Kernel.max(100 - weights(chore) * 100, 0.0)
    end
  end

  defp return_newest_chore_history(chore) do
    chore_histories =
      chore.chore_histories
      |> Enum.sort_by(& &1.completed_date, {:desc, Date})
      |> get_first_if_exists()

    new_chore = %{chore | chore_histories: chore_histories}
    countdown = days_till_next_chore(new_chore)

    Map.put(new_chore, :countdown, countdown)
    |> Map.put(:fill_percent, fill_percent_for_chore(new_chore))
  end

  defp get_first_if_exists([h | _]) do
    h
  end

  defp get_first_if_exists([]) do
    nil
  end

  @doc """
  Gets a single chore.

  Raises `Ecto.NoResultsError` if the Chore does not exist.

  ## Examples

      iex> get_chore!(123)
      %Chore{}

      iex> get_chore!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chore!(id) do
    IO.puts("get_chore!(id) id: #{id}")

    query =
      from(c in Chore,
        where: c.id == ^id,
        preload: [:chore_histories]
      )

    history = Repo.all(query) |> List.first() |> return_newest_chore_history()

    history
  end

  @doc """
  Creates a chore.

  ## Examples

      iex> create_chore(%{field: value})
      {:ok, %Chore{}}

      iex> create_chore(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chore(attrs \\ %{}) do
    {:ok, chore} =
      %Chore{}
      |> Chore.changeset(attrs)
      |> Repo.insert()

    {:ok, broadcast_update(chore)}
  end

  @doc """
  Updates a chore.

  ## Examples

      iex> update_chore(chore, %{field: new_value})
      {:ok, %Chore{}}

      iex> update_chore(chore, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chore(%Chore{} = chore, attrs) do
    {:ok, new_chore} =
      chore
      |> Chore.changeset(attrs)
      |> Repo.update()

    {:ok, broadcast_update(new_chore)}
  end

  @doc """
  Deletes a chore.

  ## Examples

      iex> delete_chore(chore)
      {:ok, %Chore{}}

      iex> delete_chore(chore)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chore(%Chore{} = chore) do
    Repo.delete(chore)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chore changes.

  ## Examples

      iex> change_chore(chore)
      %Ecto.Changeset{data: %Chore{}}

  """
  def change_chore(%Chore{} = chore, attrs \\ %{}) do
    Chore.changeset(chore, attrs)
  end

  alias Homeview.Chores.ChoreHistory

  @doc """
  Returns the list of chore_histories.

  ## Examples

      iex> list_chore_histories()
      [%ChoreHistory{}, ...]

  """
  def list_chore_histories do
    Repo.all(ChoreHistory)
  end

  @doc """
  Gets a single chore_history.

  Raises `Ecto.NoResultsError` if the Chore history does not exist.

  ## Examples

      iex> get_chore_history!(123)
      %ChoreHistory{}

      iex> get_chore_history!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chore_history!(id), do: Repo.get!(ChoreHistory, id)

  @doc """
  Creates a chore_history.

  ## Examples

      iex> create_chore_history(%{field: value})
      {:ok, %ChoreHistory{}}

      iex> create_chore_history(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chore_history(attrs \\ %{}) do
    %ChoreHistory{}
    |> ChoreHistory.changeset(attrs)
    |> Repo.insert()
  end

  def create_chore_history_by_chore_id(id) do
    params = %{completed_date: Date.utc_today()}

    Repo.get_by!(Chore, id: id)
    |> Ecto.build_assoc(:chore_histories)
    |> Ecto.Changeset.cast(params, [:completed_date])
    |> Repo.insert!()

    chore = get_chore!(id)
    broadcast(chore, :do_chore)
  end

  @doc """
  Updates a chore_history.

  ## Examples

      iex> update_chore_history(chore_history, %{field: new_value})
      {:ok, %ChoreHistory{}}

      iex> update_chore_history(chore_history, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chore_history(%ChoreHistory{} = chore_history, attrs) do
    chore_history
    |> ChoreHistory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chore_history.

  ## Examples

      iex> delete_chore_history(chore_history)
      {:ok, %ChoreHistory{}}

      iex> delete_chore_history(chore_history)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chore_history(%ChoreHistory{} = chore_history) do
    Repo.delete(chore_history)
  end

  def delete_latest_chore_history(chore_id) do
    chore = get_chore!(chore_id)
    Repo.delete(chore.chore_histories)

    broadcast_update(%{id: chore_id})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chore_history changes.

  ## Examples

      iex> change_chore_history(chore_history)
      %Ecto.Changeset{data: %ChoreHistory{}}

  """
  def change_chore_history(%ChoreHistory{} = chore_history, attrs \\ %{}) do
    ChoreHistory.changeset(chore_history, attrs)
  end
end
