defmodule Homeview.Repo.Migrations.CreatePolls do
  use Ecto.Migration

  def change do
    create table(:polls) do
      add :text, :string
      add :ready_to_vote, :boolean, default: false, null: false
      add :created_by, :string

      timestamps()
    end
  end
end
