defmodule Homeview.Accounts.AnonymousUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:user_id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :user_id}
  schema "anonymous_users" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(anonymous_user, attrs) do
    anonymous_user
    |> cast(attrs, [:user_id, :name])
    |> validate_required([:user_id])
    |> validate_length(:name, min: 1, max: 255)
    |> unique_constraint(:user_id)
  end
end
