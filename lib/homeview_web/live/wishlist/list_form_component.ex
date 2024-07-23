defmodule HomeviewWeb.ListFormComponent do
  use HomeviewWeb, :live_component
  alias Homeview.Wishlist

  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-2xl font-bold mb-4"><%= if @list.id, do: "Rediger", else: "Ny" %> Liste</h2>
      
      <.form for={@form} phx-submit="save" phx-target={@myself}>
        <div class="mb-4">
          <.input field={@form[:name]} label="Navn" />
        </div>
        
        <div class="flex justify-end">
          <.button type="submit" phx-disable-with="Lagrer...">Lagre</.button>
        </div>
      </.form>
    </div>
    """
  end

  def update(%{list: list, person_id: person_id} = assigns, socket) do
    changeset = Wishlist.change_list(list)
    {:ok, socket |> assign(assigns) |> assign(form: to_form(changeset), person_id: person_id)}
  end

  def handle_event("save", %{"list" => list_params}, socket) do
    save_list(socket, socket.assigns.list.id, list_params)
  end

  defp save_list(socket, nil, list_params) do
    case Wishlist.create_list(Map.put(list_params, "person_id", socket.assigns.person_id)) do
      {:ok, _list} ->
        send(self(), :update_person)
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_list(socket, _id, list_params) do
    case Wishlist.update_list(socket.assigns.list, list_params) do
      {:ok, _list} ->
        send(self(), :update_person)
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
