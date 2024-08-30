defmodule Homeview.Repo.Migrations.CreatePollAnswers do
  use Ecto.Migration

  def change do
    create table(:poll_answers) do
      add :answered_by, :string
      add :poll_id, references(:polls, on_delete: :nothing)
      add :poll_alternative_id, references(:poll_alternatives, on_delete: :nothing)

      timestamps()
    end

    create index(:poll_answers, [:poll_id])
    create index(:poll_answers, [:poll_alternative_id])
  end
end
