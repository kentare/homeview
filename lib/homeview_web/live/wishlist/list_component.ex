# lib/homeview_web/live/list_component.ex
defmodule HomeviewWeb.ListComponent do
  use HomeviewWeb, :live_component
  alias Homeview.Wishlist
  alias HomeviewWeb.ItemComponent

  def render(assigns) do
    ~H"""
    <div class="list bg-gray-100 rounded-lg p-4">
      <div class="flex justify-between items-center mb-2">
        <h4 class="text-lg font-medium flex items-center">
          <Heroicons.list_bullet class="h-6 w-6 mr-2" /> <%= @list.name %>
        </h4>
        
        <div class="flex gap-2">
          <button
            phx-click="edit_list"
            phx-target={@myself}
            class="text-blue-500 hover:text-blue-700 flex items-center mr-2"
          >
            <Heroicons.pencil class="h-4 w-4" />
          </button>
          
          <button
            phx-click="delete_list"
            phx-target={@myself}
            data-confirm="Are you sure?"
            class="text-red-500 hover:text-red-700 flex items-center"
          >
            <Heroicons.trash class="h-4 w-4" />
          </button>
        </div>
      </div>
      
      <div class="space-y-2">
        <%= for item <- @list.items do %>
          <.live_component module={ItemComponent} id={item.id} item={item} />
        <% end %>
      </div>
      
      <button
        phx-click="new_item"
        phx-target={@myself}
        class="mt-2 bg-green-500 hover:bg-green-700 text-white font-bold py-1 px-2 rounded text-sm focus:outline-none focus:shadow-outline flex items-center"
      >
        <Heroicons.square_2_stack class="h-5 w-5 mr-2" /> <Heroicons.plus class="h-4 w-4 mr-1" />
      </button>
    </div>
    """
  end

  def handle_event("edit_list", _, socket) do
    send(self(), {:edit_list, socket.assigns.list.id})
    {:noreply, socket}
  end

  def handle_event("delete_list", _, socket) do
    Wishlist.delete_list(socket.assigns.list)
    send(self(), :update_person)
    {:noreply, socket}
  end

  def handle_event("new_item", _, socket) do
    send(self(), {:new_item, socket.assigns.list.id})
    {:noreply, socket}
  end
end
