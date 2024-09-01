defmodule Homeview.Repo.Migrations.UpdatePollsAnonVoting do
  use Ecto.Migration

  def change do
    alter table(:polls) do
      add :hide_alternative_image_on_creation, :boolean, default: false
    end
  end
end
