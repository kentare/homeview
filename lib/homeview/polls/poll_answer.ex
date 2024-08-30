defmodule Homeview.Polls.PollAnswer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "poll_answers" do
    belongs_to :answerer, Homeview.Accounts.AnonymousUser,
      foreign_key: :answered_by_id,
      references: :user_id,
      type: :string

    belongs_to :poll, Homeview.Polls.Poll
    belongs_to :poll_alternative, Homeview.Polls.PollAlternative

    timestamps()
  end

  @doc false
  def changeset(poll_answer, attrs) do
    poll_answer
    |> cast(attrs, [:answered_by_id, :poll_id, :poll_alternative_id])
    |> validate_required([:answered_by_id, :poll_id, :poll_alternative_id])
    |> unique_constraint([:answered_by_id, :poll_id])
    |> foreign_key_constraint(:answered_by_id)
    |> foreign_key_constraint(:poll_id)
    |> foreign_key_constraint(:poll_alternative_id)
  end
end
