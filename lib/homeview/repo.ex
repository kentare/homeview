defmodule Homeview.Repo do
  use Ecto.Repo,
    otp_app: :homeview,
    adapter: Ecto.Adapters.Postgres
end
