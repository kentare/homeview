defmodule Homeview.Repo.Migrations.AddExtraTextAlternative do
  use Ecto.Migration

  def change do
    alter table(:poll_alternatives) do
      add :extra_text, :string
    end
  end
end
