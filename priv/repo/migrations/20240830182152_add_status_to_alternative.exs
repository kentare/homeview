defmodule Homeview.Repo.Migrations.AddStatusToAlternative do
  use Ecto.Migration

  def change do
    alter table(:poll_alternatives) do
      add :status, :string, default: "generating"
    end

    create constraint(:poll_alternatives, :status_enum,
             check: "status IN ('generating', 'success', 'failed')"
           )
  end
end
