defmodule HomeviewWeb.NameModalComponent do
  use HomeviewWeb, :live_component
  alias Homeview.Accounts

  def render(assigns) do
    ~H"""
    <div class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center">
      <div class="bg-white p-6 rounded-lg shadow-xl">
        <h2 class="text-xl font-bold mb-4">Please enter your name</h2>
        
        <form phx-submit="save" phx-target={@myself}>
          <input
            type="text"
            name="name"
            placeholder="Your name"
            class="border p-2 mb-4 w-full"
            required
          /> <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded">Save</button>
        </form>
      </div>
    </div>
    """
  end

  def handle_event("save", %{"name" => name}, socket) do
    user_id = socket.assigns.current_user_id

    case Accounts.update_anonymous_user_name(user_id, name) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Name saved successfully")
         |> push_redirect(to: ~p"/polls")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to save name")}
    end
  end
end
