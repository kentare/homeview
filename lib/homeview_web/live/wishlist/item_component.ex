# lib/homeview_web/live/item_component.ex
defmodule HomeviewWeb.ItemComponent do
  use HomeviewWeb, :live_component
  alias Homeview.Wishlist
  require Decimal

  def render(assigns) do
    ~H"""
    <div class="item bg-white shadow rounded-lg p-4">
      <div class="flex justify-between items-start">
        <div>
          <h5 class="text-md font-semibold mb-2 flex items-center">
            <Heroicons.square_2_stack class="h-5 w-5 mr-2" /> <%= @item.name %>
          </h5>
          
          <p class="text-sm text-gray-600 mb-1"><%= @item.description %></p>
          
          <%= if @item.price do %>
            <p class="text-sm mb-1">
              Pris: <span class="font-medium"><%= format_price(@item.price) %></span>
            </p>
          <% end %>
          
          <%!-- <%= if @item.priority do %>
            <p class="text-sm mb-1">
              Priority: <span class="font-medium"><%= @item.priority %></span>
            </p>
          <% end %> --%>
          <%= if @item.status do %>
            <p class="text-sm mb-1">Status: <span class="font-medium"><%= @item.status %></span></p>
          <% end %>
          
          <%= if @item.url do %>
            <a
              href={@item.url}
              target="_blank"
              rel="noopener noreferrer"
              class="text-blue-500 hover:text-blue-700 text-sm flex items-center"
            >
              <Heroicons.link class="h-4 w-4 mr-1" /> Gå til nettside
            </a>
          <% end %>
        </div>
        
        <div class="flex gap-2 items-end h-full self-end">
          <button
            phx-click="edit_item"
            phx-target={@myself}
            class="text-blue-500 hover:text-blue-700 flex items-center"
          >
            <Heroicons.pencil class="h-4 w-4" />
          </button>
          
          <button
            phx-click="delete_item"
            phx-target={@myself}
            data-confirm="Are you sure?"
            class="text-red-500 hover:text-red-700 flex items-center"
          >
            <Heroicons.trash class="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("edit_item", _, socket) do
    send(self(), {:edit_item, socket.assigns.item.id})
    {:noreply, socket}
  end

  def handle_event("delete_item", _, socket) do
    Wishlist.delete_item(socket.assigns.item)
    send(self(), :update_list)
    {:noreply, socket}
  end

  defp format_price(price) when is_nil(price), do: "N/A"

  defp format_price(price) when is_float(price),
    do: "#{:erlang.float_to_binary(price, decimals: 2)}"

  defp format_price(price) when is_integer(price),
    do: "#{price}.00"

  defp format_price(price) when Decimal.is_decimal(price),
    do: "#{Decimal.to_string(price)}"

  defp format_price(_), do: "N/A"
end
