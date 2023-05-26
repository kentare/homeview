defmodule HomeviewWeb.ChoreHistoryLive.FormComponent do
  use HomeviewWeb, :live_component

  alias Homeview.Chores

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage chore_history records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="chore_history-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:chore_id]} type="number" label="Chore" required />
        <.input field={@form[:completed_date]} type="date" label="Completed date" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Chore history</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{chore_history: chore_history} = assigns, socket) do
    changeset = Chores.change_chore_history(chore_history)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"chore_history" => chore_history_params}, socket) do
    changeset =
      socket.assigns.chore_history
      |> Chores.change_chore_history(chore_history_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"chore_history" => chore_history_params}, socket) do
    save_chore_history(socket, socket.assigns.action, chore_history_params)
  end

  defp save_chore_history(socket, :edit, chore_history_params) do
    case Chores.update_chore_history(socket.assigns.chore_history, chore_history_params) do
      {:ok, chore_history} ->
        notify_parent({:saved, chore_history})

        {:noreply,
         socket
         |> put_flash(:info, "Chore history updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_chore_history(socket, :new, chore_history_params) do
    case Chores.create_chore_history(chore_history_params) do
      {:ok, chore_history} ->
        notify_parent({:saved, chore_history})

        {:noreply,
         socket
         |> put_flash(:info, "Chore history created successfully")
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
