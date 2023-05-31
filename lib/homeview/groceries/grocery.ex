defmodule Homeview.Groceries.Grocery do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groceries" do
    field(:amount, :integer, default: 1)
    field(:bought, :time)
    field(:name, :string)
    field(:unit, :string, default: "stk")

    timestamps()
  end

  @doc false
  def changeset(grocery, attrs) do
    grocery
    |> cast(attrs, [:name, :bought, :amount, :unit])
    |> validate_required([:name, :amount, :unit])
    |> validate_length(:name, min: 2, message: "Må være minst %{count} bokstaver")
  end
end
