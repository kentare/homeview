defmodule HomeviewWeb.ChoreLive.Show do
  use HomeviewWeb, :live_view

  alias Homeview.Chores

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:chore, Chores.get_chore!(id))}
  end

  defp page_title(:show), do: "Show Chore"
  defp page_title(:edit), do: "Edit Chore"
end
