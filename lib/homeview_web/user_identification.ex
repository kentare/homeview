defmodule HomeviewWeb.UserIdentification do
  import Plug.Conn
  alias Homeview.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :user_id) do
      nil ->
        user_id = generate_user_id()
        {:ok, _user} = Accounts.get_or_create_anonymous_user(user_id)

        conn
        |> put_session(:user_id, user_id)
        |> assign(:current_user_id, user_id)
        |> assign_user_name(user_id)

      user_id ->
        conn
        |> assign(:current_user_id, user_id)
        |> assign_user_name(user_id)
    end
  end

  defp generate_user_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16()
  end

  defp assign_user_name(conn, user_id) do
    name = Accounts.get_anonymous_user_name(user_id)
    assign(conn, :current_name, name)
  end
end
