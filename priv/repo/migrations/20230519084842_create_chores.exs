defmodule Homeview.Repo.Migrations.CreateChores do
  use Ecto.Migration

  def change do
    create table(:chores) do
      add :name, :string
      add :time_interval, :integer
      add :iconUrl, :string

      timestamps()
    end
  end
end
