defmodule Homeview.Chores.Chore do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chores" do
    field :iconUrl, :string
    field :name, :string
    field :time_interval, :integer
    has_many :chore_histories, Homeview.Chores.ChoreHistory

    timestamps()
  end

  @doc false
  def changeset(chore, attrs) do
    chore
    |> cast(attrs, [:name, :time_interval, :iconUrl])
    |> validate_required([:name, :time_interval])
  end
end
