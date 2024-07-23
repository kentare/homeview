defmodule Homeview.Repo.Migrations.CreateLists do
  use Ecto.Migration

  def change do
    create table(:lists) do
      add :name, :string
      add :person_id, references(:persons, on_delete: :nothing)

      timestamps()
    end

    create index(:lists, [:person_id])
  end
end
