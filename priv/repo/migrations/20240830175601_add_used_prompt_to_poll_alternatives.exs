defmodule Homeview.Repo.Migrations.AddUsedPromptToPollAlternatives do
  use Ecto.Migration

  def change do
    alter table(:poll_alternatives) do
      add :prompt, :text
    end
  end
end
