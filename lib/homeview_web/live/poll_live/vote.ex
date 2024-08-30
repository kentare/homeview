defmodule HomeviewWeb.PollLive.Vote do
  use HomeviewWeb, :live_view
  alias Homeview.Polls

  @impl true
  def mount(%{"id" => id}, session, socket) do
    poll = Polls.get_poll!(id)
    socket = socket |> cookie_assigns(session)
    has_voted = Polls.user_has_voted?(poll.id, socket.assigns.current_user_id)
    vote = Polls.user_vote(poll.id, socket.assigns.current_user_id)
    dbg(vote)

    {:ok,
     assign(socket,
       poll: poll,
       user_id: socket.assigns.current_user_id,
       has_voted: has_voted,
       vote: vote
     )}
  end

  @impl true
  def handle_event("vote", %{"alternative_id" => alternative_id}, socket) do
    case Polls.create_poll_answer(%{
           poll_id: socket.assigns.poll.id,
           poll_alternative_id: alternative_id,
           answered_by_id: socket.assigns.current_user_id
         }) do
      {:ok, _answer} ->
        vote = Polls.user_vote(socket.assigns.poll.id, socket.assigns.current_user_id)
        dbg(vote)

        {:noreply,
         socket
         |> put_flash(:info, "Vote recorded successfully")
         |> assign(has_voted: true, vote: vote)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to record vote")}
    end
  end
end
