defmodule Homeview.Polls do
  @moduledoc """
  The Polls context.
  """

  import Ecto.Query, warn: false
  alias Homeview.Repo

  alias Homeview.Polls.{Poll, PollAlternative, PollAnswer}

  @doc """
  Returns the list of polls.

  ## Examples

      iex> list_polls()
      [%Poll{}, ...]

  """
  def list_polls do
    Repo.all(Poll)
  end

  @doc """
  Gets a single poll.

  Raises `Ecto.NoResultsError` if the Poll does not exist.

  ## Examples

      iex> get_poll!(123)
      %Poll{}

      iex> get_poll!(456)
      ** (Ecto.NoResultsError)

  """
  def get_poll!(id) do
    Poll
    |> Repo.get!(id)
    |> Repo.preload([:poll_alternatives, poll_alternatives: :creator])
    |> Repo.preload(:creator)
  end

  @doc """
  Creates a poll.

  ## Examples

      iex> create_poll(%{field: value})
      {:ok, %Poll{}}

      iex> create_poll(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_poll(attrs \\ %{}) do
    %Poll{}
    |> Poll.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a poll.

  ## Examples

      iex> update_poll(poll, %{field: new_value})
      {:ok, %Poll{}}

      iex> update_poll(poll, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_poll(%Poll{} = poll, attrs) do
    poll
    |> Poll.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a poll.

  ## Examples

      iex> delete_poll(poll)
      {:ok, %Poll{}}

      iex> delete_poll(poll)
      {:error, %Ecto.Changeset{}}

  """
  def delete_poll(%Poll{} = poll) do
    Repo.transaction(fn ->
      # Delete all poll answers associated with this poll
      Repo.delete_all(from(pa in PollAnswer, where: pa.poll_id == ^poll.id))

      # Delete all poll alternatives associated with this poll
      Repo.delete_all(from(pa in PollAlternative, where: pa.poll_id == ^poll.id))

      # Finally, delete the poll itself
      Repo.delete!(poll)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking poll changes.

  ## Examples

      iex> change_poll(poll)
      %Ecto.Changeset{data: %Poll{}}

  """
  def change_poll(%Poll{} = poll, attrs \\ %{}) do
    Poll.changeset(poll, attrs)
  end

  def create_poll_alternative(attrs \\ %{}) do
    %PollAlternative{}
    |> PollAlternative.changeset(attrs)
    |> Repo.insert()
  end

  def change_poll_alternative(%PollAlternative{} = poll_alternative, attrs \\ %{}) do
    PollAlternative.changeset(poll_alternative, attrs)
  end

  def get_poll_alternatives(poll_id, user_id) do
    query =
      from pa in PollAlternative,
        where: pa.poll_id == ^poll_id and pa.created_by == ^user_id

    Repo.all(query)
  end

  @spec get_poll_alternative(integer()) :: %PollAlternative{} | no_return()
  def get_poll_alternative(id) do
    Repo.get!(PollAlternative, id)
  end

  def update_poll_alternative(%PollAlternative{} = poll_alternative, attrs) do
    poll_alternative
    |> PollAlternative.changeset(attrs)
    |> Repo.update()
  end

  def create_poll_answer(attrs \\ %{}) do
    # TODO: Check if user has already voted

    vote = user_vote(attrs.poll_id, attrs.answered_by_id)

    if vote do
      vote
      |> PollAnswer.changeset(attrs)
      |> Repo.update()
    else
      %PollAnswer{}
      |> PollAnswer.changeset(attrs)
      |> Repo.insert()
    end
  end

  @doc """
  Returns the list of polls that are ready for voting.
  """
  def list_ready_polls do
    query =
      from p in Poll,
        where: p.ready_to_vote == true,
        order_by: [desc: p.inserted_at],
        preload: [:poll_answers, :creator]

    Repo.all(query)
  end

  @doc """
  Returns the list of polls that are not ready for voting.
  """
  def list_not_ready_polls do
    query = from p in Poll, where: p.ready_to_vote == false, order_by: [desc: p.inserted_at]
    Repo.all(query)
  end

  @doc """
  Checks if a user has already voted in a specific poll.
  """
  def user_has_voted?(poll_id, user_id)
      when (is_binary(poll_id) or is_integer(poll_id)) and is_binary(user_id) do
    query =
      from pa in PollAnswer,
        where: pa.poll_id == ^poll_id and pa.answered_by_id == ^user_id,
        select: count(pa.id)

    Repo.one(query) > 0
  end

  def user_has_voted?(_poll_id, _user_id) do
    false
  end

  def user_vote(poll_id, user_id)
      when (is_binary(poll_id) or is_integer(poll_id)) and
             is_binary(user_id) do
    query =
      from pa in PollAnswer,
        where: pa.poll_id == ^poll_id and pa.answered_by_id == ^user_id

    Repo.one(query)
  end

  def user_vote(_poll_id, _user_id) do
    nil
  end

  @doc """
  Gets the results for a specific poll, including the total votes and percentages.
  """
  def get_poll_results(poll_id) do
    poll = get_poll!(poll_id)

    answers_query =
      from pa in PollAnswer,
        where: pa.poll_id == ^poll_id,
        group_by: pa.poll_alternative_id,
        select: {pa.poll_alternative_id, count(pa.id)}

    results = Repo.all(answers_query)
    total_votes = Enum.sum(Enum.map(results, fn {_, count} -> count end))

    results_with_percentage =
      Enum.map(results, fn {alternative_id, count} ->
        alternative = Enum.find(poll.poll_alternatives, &(&1.id == alternative_id))
        percentage = if total_votes > 0, do: count / total_votes * 100, else: 0
        {alternative, count, percentage}
      end)

    {results_with_percentage, total_votes}
  end

  @doc """
  Updates the ready status of a poll alternative.
  """
  def update_poll_alternative_ready_status(alternative_id, is_ready) do
    alternative = Repo.get!(PollAlternative, alternative_id)

    alternative
    |> PollAlternative.changeset(%{is_ready: is_ready})
    |> Repo.update()
  end

  @doc """
  Checks if all alternatives for a poll are ready.
  """
  def all_alternatives_ready?(poll_id) do
    query =
      from pa in PollAlternative,
        where: pa.poll_id == ^poll_id,
        select: count(pa.id) == count(pa.id, pa.is_ready == true)

    Repo.one(query)
  end

  def delete_poll_alternative(id) do
    Repo.delete(Repo.get!(PollAlternative, id))
  end
end
