defmodule HomeviewWeb.ChoreLive.Index do
  use HomeviewWeb, :live_view

  alias Homeview.Chores
  alias Homeview.Chores.Chore

  alias HomeviewWeb.Clock

  @impl true
  def mount(_params, _session, socket) do
    if(connected?(socket)) do
      Chores.subscribe()
    end

    {:ok, stream(socket, :chores, Chores.list_chores()) |> Clock.assign_time()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Chore")
    |> assign(:chore, Chores.get_chore!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Chore")
    |> assign(:chore, %Chore{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Chores")
    |> assign(:chore, nil)
  end

  def handle_event("do_task", %{"id" => id}, socket) do
    chore = Chores.get_chore!(id)

    if(chore.countdown == chore.time_interval) do
      {:noreply, socket}
    else
      Chores.create_chore_history_by_chore_id(id)
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    chore = Chores.get_chore!(id)
    {:ok, _} = Chores.delete_chore(chore)

    {:noreply, stream_delete(socket, :chores, chore)}
  end

  @impl true
  def handle_event("delete_last_history", %{"id" => id}, socket) do
    _chore = Chores.delete_latest_chore_history(id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:update_chore, chore}, socket) do
    {:noreply, stream_insert(socket, :chores, chore)}
  end

  @impl true
  def handle_info({:do_chore, chore}, socket) do
    {:noreply, stream_insert(socket, :chores, Map.put(chore, :class, "race-back"))}
  end
end
