defmodule HomeviewWeb.ChoreLive.FormComponent do
  use HomeviewWeb, :live_component

  alias Homeview.Chores

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage chore records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="chore-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:time_interval]} type="number" label="Time interval" />
        <.input field={@form[:iconUrl]} type="text" label="Iconurl" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Chore</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{chore: chore} = assigns, socket) do
    changeset = Chores.change_chore(chore)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"chore" => chore_params}, socket) do
    changeset =
      socket.assigns.chore
      |> Chores.change_chore(chore_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"chore" => chore_params}, socket) do
    save_chore(socket, socket.assigns.action, chore_params)
  end

  defp save_chore(socket, :edit, chore_params) do
    case Chores.update_chore(socket.assigns.chore, chore_params) do
      {:ok, chore} ->
        notify_parent({:saved, chore})

        {:noreply,
         socket
         |> put_flash(:info, "Chore updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_chore(socket, :new, chore_params) do
    case Chores.create_chore(chore_params) do
      {:ok, chore} ->
        notify_parent({:saved, chore})

        {:noreply,
         socket
         |> put_flash(:info, "Chore created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
