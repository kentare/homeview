defmodule Homeview.Wishlist.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :name, :string
    field :priority, :integer
    field :status, :string
    field :description, :string
    field :url, :string
    field :price, :decimal
    belongs_to :list, Homeview.Wishlist.List

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :description, :price, :url, :priority, :status, :list_id])
    |> validate_required([:name, :list_id])
    |> foreign_key_constraint(:list_id)
  end
end
