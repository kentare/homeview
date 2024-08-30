defmodule Homeview.Repo.Migrations.AlterTextFieldsToText do
  use Ecto.Migration

  def change do
    alter table(:poll_alternatives) do
      modify :text, :text
      modify :image_url, :text
      modify :extra_text, :text
    end

    alter table(:polls) do
      modify :text, :text
    end
  end
end
