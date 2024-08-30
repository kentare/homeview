defmodule Homeview.Repo.Migrations.CreateAnonymousUsers do
  use Ecto.Migration

  def change do
    create table(:anonymous_users) do
      add :user_id, :string, null: false
      add :name, :string

      timestamps()
    end

    create unique_index(:anonymous_users, [:user_id])
  end
end
