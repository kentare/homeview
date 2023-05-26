defmodule Homeview.Repo.Migrations.CreateChoreHistories do
  use Ecto.Migration

  def change do
    create table(:chore_histories) do
      add :completed_date, :date
      add :chore_id, references(:chores, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:chore_histories, [:chore_id])
  end
end
