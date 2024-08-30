defmodule Homeview.Polls.Poll do
  use Ecto.Schema
  import Ecto.Changeset

  schema "polls" do
    field :text, :string
    field :ready_to_vote, :boolean, default: false

    belongs_to :creator, Homeview.Accounts.AnonymousUser,
      foreign_key: :created_by_id,
      references: :user_id,
      type: :string

    has_many :poll_alternatives, Homeview.Polls.PollAlternative
    has_many :poll_answers, Homeview.Polls.PollAnswer

    timestamps()
  end

  @doc false
  def changeset(poll, attrs) do
    poll
    |> cast(attrs, [:text, :ready_to_vote, :created_by_id])
    |> validate_required([:text, :created_by_id])
    |> foreign_key_constraint(:created_by_id)
  end
end
