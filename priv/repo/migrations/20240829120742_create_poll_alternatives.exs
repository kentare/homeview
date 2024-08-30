defmodule Homeview.Repo.Migrations.CreatePollAlternatives do
  use Ecto.Migration

  def change do
    create table(:poll_alternatives) do
      add :text, :string
      add :image_url, :string
      add :created_by, :string
      add :is_ready, :boolean, default: false, null: false
      add :poll_id, references(:polls, on_delete: :nothing)

      timestamps()
    end

    create index(:poll_alternatives, [:poll_id])
  end
end
