# lib/homeview_web/live/person_form_component.ex
defmodule HomeviewWeb.PersonFormComponent do
  use HomeviewWeb, :live_component
  alias Homeview.Wishlist

  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-2xl font-bold mb-4">
        <%= if @person.id, do: "Rediger", else: "Ny" %> ønskeliste
      </h2>
      
      <.form for={@form} phx-submit="save" phx-target={@myself}>
        <div class="mb-4">
          <.input field={@form[:name]} label="Navn" />
        </div>
        
        <div class="mb-4">
          <.input field={@form[:important]} label="Framhevet" type="checkbox" />
        </div>
        
        <div class="flex justify-end">
          <.button type="submit" phx-disable-with="Saving...">Save</.button>
        </div>
      </.form>
    </div>
    """
  end

  def update(%{person: person} = assigns, socket) do
    changeset = Wishlist.change_person(person)
    {:ok, socket |> assign(assigns) |> assign_form(changeset)}
  end

  def handle_event("save", %{"person" => person_params}, socket) do
    save_person(socket, socket.assigns.person.id, person_params)
  end

  defp save_person(socket, nil, person_params) do
    case Wishlist.create_person(person_params) do
      {:ok, _person} ->
        send(self(), :update_person)
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_person(socket, _id, person_params) do
    case Wishlist.update_person(socket.assigns.person, person_params) do
      {:ok, _person} ->
        send(self(), :update_person)
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
