defmodule Homeview.Polls.PollAlternative do
  use Ecto.Schema
  import Ecto.Changeset

  schema "poll_alternatives" do
    field :text, :string
    field :prompt, :string
    field :image_url, :string
    field :is_ready, :boolean, default: false
    field :extra_text, :string
    field :status, :string, default: "failed"

    belongs_to :creator, Homeview.Accounts.AnonymousUser,
      foreign_key: :created_by_id,
      references: :user_id,
      type: :string

    belongs_to :poll, Homeview.Polls.Poll

    timestamps()
  end

  @doc false
  def changeset(poll_alternative, attrs) do
    poll_alternative
    |> cast(attrs, [
      :text,
      :image_url,
      :created_by_id,
      :is_ready,
      :poll_id,
      :extra_text,
      :prompt,
      :status
    ])
    |> validate_required([:text, :created_by_id, :poll_id, :status])
    |> validate_length(:text, min: 10)
    |> foreign_key_constraint(:created_by_id)
    |> foreign_key_constraint(:poll_id)
    |> validate_inclusion(:status, ["generating", "success", "failed"])
  end
end
