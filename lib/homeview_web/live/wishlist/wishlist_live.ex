# lib/homeview_web/live/wishlist_live.ex
defmodule HomeviewWeb.WishlistLive do
  use HomeviewWeb, :live_view
  alias Homeview.Wishlist
  alias HomeviewWeb.{PersonComponent, PersonFormComponent, ListFormComponent, ItemFormComponent}

  def mount(_params, _session, socket) do
    {:ok, assign(socket, persons: list_persons(), show_modal: false, modal_type: nil)}
  end

  def handle_params(%{"id" => id}, _, socket) do
    person = Wishlist.get_person!(id)
    {:noreply, assign(socket, selected_person: person, page_title: person.name)}
  end

  def handle_params(_, _, socket) do
    {:noreply, assign(socket, selected_person: nil, page_title: "Ønskelister")}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-6"><%= @page_title %></h1>
      
      <%= if is_nil(@selected_person) do %>
        <button
          phx-click="new_person"
          class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded mb-4 flex items-center"
        >
          <Heroicons.user_plus class="h-5 w-5 mr-2" /> <Heroicons.plus class="h-4 w-4 mr-1" />
          Legg til
        </button>
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <%= for person <- @persons do %>
            <div class="bg-white shadow-md rounded px-8 pt-6 pb-8 mb-4">
              <h3 class="text-xl font-semibold mb-4">
                <.link
                  navigate={~p"/wishlist/#{person}"}
                  class="text-blue-500 hover:text-blue-700 flex items-center"
                >
                  <Heroicons.user class="h-6 w-6 mr-2" /> <%= person.name %>
                </.link>
                
                <span class={"ml-2 px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{if person.important, do: "bg-green-100 text-green-800", else: "bg-gray-100 text-gray-800"}"}>
                  <%= if person.important, do: "VIP", else: "" %>
                </span>
              </h3>
              
              <div class="flex justify-end space-x-2">
                <button
                  phx-click="edit_person"
                  phx-value-id={person.id}
                  class="text-blue-500 hover:text-blue-700 flex items-center"
                >
                  <Heroicons.pencil class="h-4 w-4" />
                </button>
                
                <button
                  phx-click="delete_person"
                  phx-value-id={person.id}
                  data-confirm="Are you sure?"
                  class="text-red-500 hover:text-red-700 flex items-center"
                >
                  <Heroicons.trash class="h-4 w-4" />
                </button>
              </div>
            </div>
          <% end %>
        </div>
      <% else %>
        <.link
          navigate={~p"/wishlist"}
          class="text-blue-500 hover:text-blue-700 mb-4  flex items-center"
        >
          <Heroicons.arrow_left class="h-5 w-5 mr-1" /> Tilbake til ønskelister
        </.link>
        
        <.live_component module={PersonComponent} id={@selected_person.id} person={@selected_person} />
      <% end %>
      
      <.modal :if={@show_modal} id="form-modal" show={@show_modal} on_cancel={JS.push("close_modal")}>
        <%= case @modal_type do %>
          <% :person -> %>
            <.live_component module={PersonFormComponent} id={@person.id || :new} person={@person} />
          <% :list -> %>
            <.live_component
              module={ListFormComponent}
              id={@list.id || :new}
              list={@list}
              person_id={@selected_person.id}
            />
          <% :item -> %>
            <.live_component
              person_id={@selected_person.id}
              module={ItemFormComponent}
              id={@item.id || :new}
              list_id={@list_id}
              item={@item}
            />
        <% end %>
      </.modal>
    </div>
    """
  end

  def handle_event("new_person", _, socket) do
    {:noreply, assign(socket, show_modal: true, modal_type: :person, person: %Wishlist.Person{})}
  end

  def handle_event("edit_person", %{"id" => id}, socket) do
    person = Wishlist.get_person!(id)
    {:noreply, assign(socket, show_modal: true, modal_type: :person, person: person)}
  end

  def handle_event("delete_person", %{"id" => id}, socket) do
    person = Wishlist.get_person!(id)
    {:ok, _} = Wishlist.delete_person(person)
    {:noreply, assign(socket, persons: list_persons())}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, show_modal: false, modal_type: nil)}
  end

  def handle_info({:new_list, person_id}, socket) do
    {:noreply,
     assign(socket,
       show_modal: true,
       modal_type: :list,
       list: %Wishlist.List{},
       person_id: person_id
     )}
  end

  def handle_info({:edit_list, list_id}, socket) do
    list = Wishlist.get_list!(list_id)
    {:noreply, assign(socket, show_modal: true, modal_type: :list, list: list)}
  end

  def handle_info({:new_item, list_id}, socket) do
    {:noreply,
     assign(socket,
       show_modal: true,
       modal_type: :item,
       item: %Wishlist.Item{list_id: list_id},
       list_id: list_id
     )}
  end

  def handle_info({:edit_item, item_id}, socket) do
    item = Wishlist.get_item!(item_id)

    {:noreply,
     assign(socket, show_modal: true, modal_type: :item, item: item, list_id: item.list_id)}
  end

  def handle_info(:update_person, socket) do
    updated_persons = list_persons()

    updated_selected_person =
      if socket.assigns[:selected_person],
        do: Enum.find(updated_persons, &(&1.id == socket.assigns.selected_person.id)),
        else: nil

    {:noreply,
     assign(socket,
       persons: updated_persons,
       selected_person: updated_selected_person,
       show_modal: false,
       modal_type: nil
     )}
  end

  def handle_info(:update_list, socket) do
    updated_persons = list_persons()

    updated_selected_person =
      if socket.assigns[:selected_person],
        do: Enum.find(updated_persons, &(&1.id == socket.assigns.selected_person.id)),
        else: nil

    {:noreply,
     assign(socket,
       persons: updated_persons,
       selected_person: updated_selected_person,
       show_modal: false,
       modal_type: nil
     )}
  end

  defp list_persons do
    Wishlist.list_persons()
    |> Enum.sort_by(&(!&1.important))
  end
end
