defmodule Homeview.Repo.Migrations.UpdateAnonymousUsersPrimaryKey do
  use Ecto.Migration

  def change do
    drop_if_exists table(:anonymous_users)

    create table(:anonymous_users, primary_key: false) do
      add :user_id, :string, primary_key: true
      add :name, :string

      timestamps()
    end

    create unique_index(:anonymous_users, [:user_id])

    alter table(:polls) do
      remove :created_by

      add :created_by_id,
          references(:anonymous_users, column: :user_id, type: :string, on_delete: :nilify_all)
    end

    alter table(:poll_answers) do
      remove :answered_by

      add :answered_by_id,
          references(:anonymous_users, column: :user_id, type: :string, on_delete: :nilify_all)
    end

    alter table(:poll_alternatives) do
      remove :created_by

      add :created_by_id,
          references(:anonymous_users, column: :user_id, type: :string, on_delete: :nilify_all)
    end

    create index(:polls, [:created_by_id])
    create index(:poll_answers, [:answered_by_id])
    create index(:poll_alternatives, [:created_by_id])
  end
end
