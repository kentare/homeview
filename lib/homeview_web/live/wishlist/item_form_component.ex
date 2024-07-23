# lib/homeview_web/live/item_form_component.ex
defmodule HomeviewWeb.ItemFormComponent do
  use HomeviewWeb, :live_component
  alias Homeview.Wishlist

  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-2xl font-bold mb-4"><%= if @item.id, do: "Rediger", else: "Nytt" %> ønske</h2>
      
      <.form for={@form} phx-submit="save" phx-target={@myself}>
        <div class="mb-4">
          <.input field={@form[:name]} label="Navn" />
        </div>
        
        <div class="mb-4">
          <.input field={@form[:description]} label="Beskrivelse" />
        </div>
        
        <div class="mb-4">
          <.input field={@form[:price]} label="Pris (Optional)" type="number" step="0.01" />
        </div>
        
        <div class="mb-4">
          <.input field={@form[:url]} label="URL" />
        </div>
        
        <%!-- <div class="mb-4">
          <.input field={@form[:priority]} label="Priority" type="number" />
        </div> --%>
        <div class="mb-4">
          <.input field={@form[:status]} label="Status" />
        </div>
        
        <div class="flex justify-end">
          <.button type="submit" phx-disable-with="Lagrer...">Lagre</.button>
        </div>
      </.form>
    </div>
    """
  end

  def update(%{item: item, list_id: list_id} = assigns, socket) do
    changeset = Wishlist.change_item(item)
    {:ok, socket |> assign(assigns) |> assign_form(changeset) |> assign(list_id: list_id)}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    save_item(socket, socket.assigns.item.id, item_params)
  end

  defp save_item(socket, nil, item_params) do
    case Wishlist.create_item(item_params |> Map.put("list_id", socket.assigns.list_id)) do
      {:ok, _item} ->
        send(self(), :update_person)

        {:noreply,
         socket
         |> put_flash(:info, "Item created successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_item(socket, _id, item_params) do
    case Wishlist.update_item(socket.assigns.item, item_params) do
      {:ok, _item} ->
        send(self(), :update_list)

        {:noreply,
         socket
         |> put_flash(:info, "Item updated successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
