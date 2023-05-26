defmodule Homeview.Chores.ChoreHistory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chore_histories" do
    field :completed_date, :date
    belongs_to :chore, Homeview.Chores.Chore

    timestamps()
  end

  @doc false
  def changeset(chore_history, attrs) do
    chore_history
    |> cast(attrs, [:completed_date, :chore_id])
    |> validate_required([:completed_date, :chore_id])
  end
end
