defmodule Homeview.Repo.Migrations.CreateGroceries do
  use Ecto.Migration

  def change do
    create table(:groceries) do
      add(:name, :string)
      add(:bought, :time, null: true)
      add(:amount, :integer)
      add(:unit, :string)

      timestamps()
    end
  end
end
