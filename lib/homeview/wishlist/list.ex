defmodule Homeview.Wishlist.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :name, :string
    belongs_to :person, Homeview.Wishlist.Person
    has_many :items, Homeview.Wishlist.Item

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:name, :person_id])
    |> validate_required([:name, :person_id])
    |> foreign_key_constraint(:person_id)
  end
end
