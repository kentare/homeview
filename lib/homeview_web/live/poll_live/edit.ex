defmodule HomeviewWeb.PollLive.Edit do
  use HomeviewWeb, :live_view
  alias Homeview.Polls
  alias Homeview.Polls.PollAlternative

  @impl true
  def mount(%{"id" => id}, session, socket) do
    poll = Polls.get_poll!(id)
    changeset = Polls.change_poll(poll)

    if(connected?(socket)) do
      Homeview.GeneratePubsub.subscribe()
    end

    socket = socket |> cookie_assigns(session)

    alternative_changeset =
      Polls.change_poll_alternative(%PollAlternative{
        poll_id: poll.id,
        created_by_id: socket.assigns.current_user_id
      })

    {:ok,
     socket
     |> assign(poll: poll, changeset: to_form(changeset))
     |> assign(new_alternative: to_form(alternative_changeset))}
  end

  @impl true
  def handle_info({:poll_updated}, socket) do
    poll = Polls.get_poll!(socket.assigns.poll.id)
    {:noreply, assign(socket, poll: poll)}
  end

  def handle_event("validate_alternative", %{"poll_alternative" => alternative_params}, socket) do
    alternative_params = Map.put(alternative_params, "poll_id", socket.assigns.poll.id)
    alternative_params = Map.put(alternative_params, "is_ready", false)

    new_alternative =
      Polls.change_poll_alternative(%PollAlternative{}, alternative_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, new_alternative: to_form(new_alternative))}
  end

  @impl true
  def handle_event("add_alternative", %{"poll_alternative" => alternative_params}, socket) do
    alternative_params = Map.put(alternative_params, "poll_id", socket.assigns.poll.id)
    alternative_params = Map.put(alternative_params, "is_ready", true)
    alternative_params = Map.put(alternative_params, "status", "generating")

    case Polls.create_poll_alternative(alternative_params) do
      {:ok, alternative} ->
        %{"id" => alternative.id} |> Homeview.GenerateImage.new() |> Oban.insert()

        {:noreply,
         socket
         |> put_flash(:info, "Alternative added successfully")
         |> assign(
           new_alternative:
             to_form(
               Polls.change_poll_alternative(%PollAlternative{
                 poll_id: socket.assigns.poll.id,
                 created_by_id: socket.assigns.current_user_id
               })
             )
         )
         |> assign(poll: Polls.get_poll!(socket.assigns.poll.id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, new_alternative: changeset)}
    end
  end

  @impl true
  def handle_event("toggle_ready", _, socket) do
    case Polls.update_poll(socket.assigns.poll, %{
           ready_to_vote: !socket.assigns.poll.ready_to_vote
         }) do
      {:ok, updated_poll} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           if(updated_poll.ready_to_vote,
             do: "Påll er no klar for røysting",
             else: "Påll er ikkje lenger klar for røysting"
           )
         )
         |> assign(poll: updated_poll)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to set poll as ready")}
    end
  end

  @impl true
  def handle_event("delete_alternative", %{"id" => id}, socket) do
    Polls.delete_poll_alternative(id)

    {:noreply, socket |> assign(poll: Polls.get_poll!(socket.assigns.poll.id))}
  end
end
