defmodule HomeviewWeb.ChoreHistoryLive.Index do
  use HomeviewWeb, :live_view

  alias Homeview.Chores
  alias Homeview.Chores.ChoreHistory

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :chore_histories, Chores.list_chore_histories())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Chore history")
    |> assign(:chore_history, Chores.get_chore_history!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Chore history")
    |> assign(:chore_history, %ChoreHistory{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Chore histories")
    |> assign(:chore_history, nil)
  end

  @impl true
  def handle_info({HomeviewWeb.ChoreHistoryLive.FormComponent, {:saved, chore_history}}, socket) do
    {:noreply, stream_insert(socket, :chore_histories, chore_history)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    chore_history = Chores.get_chore_history!(id)
    {:ok, _} = Chores.delete_chore_history(chore_history)

    {:noreply, stream_delete(socket, :chore_histories, chore_history)}
  end
end
