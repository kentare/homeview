defmodule Homeview.Wishlist.Person do
  use Ecto.Schema
  import Ecto.Changeset

  schema "persons" do
    field :name, :string
    field :important, :boolean, default: false
    has_many :lists, Homeview.Wishlist.List

    timestamps()
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:name, :important])
    |> validate_required([:name])
  end
end
