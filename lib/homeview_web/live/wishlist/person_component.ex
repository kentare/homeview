defmodule HomeviewWeb.PersonComponent do
  use HomeviewWeb, :live_component
  alias HomeviewWeb.ListComponent

  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <%= for list <- @person.lists do %>
        <.live_component module={ListComponent} id={list.id} list={list} />
      <% end %>
      
      <button
        phx-click="new_list"
        phx-target={@myself}
        class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline flex items-center"
      >
        <Heroicons.list_bullet class="h-5 w-5 mr-2" /> <Heroicons.plus class="h-4 w-4 mr-1" />
        Ny liste
      </button>
    </div>
    """
  end

  def handle_event("new_list", _, socket) do
    send(self(), {:new_list, socket.assigns.person.id})
    {:noreply, socket}
  end
end
