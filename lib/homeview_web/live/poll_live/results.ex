defmodule HomeviewWeb.PollLive.Results do
  use HomeviewWeb, :live_view
  alias Homeview.Polls

  @impl true
  def mount(%{"id" => id}, session, socket) do
    poll = Polls.get_poll!(id)
    {results, total_votes} = Polls.get_poll_results(id)

    all_alternatives = poll.poll_alternatives
    all_results = merge_results(all_alternatives, results)
    winner = find_winner(all_results)

    socket = socket |> cookie_assigns(session)

    {:ok,
     assign(socket, poll: poll, results: all_results, total_votes: total_votes, winner: winner)}
  end

  defp merge_results(alternatives, results) do
    result_map =
      Map.new(results, fn {alt, count, percentage} -> {alt.id, {alt, count, percentage}} end)

    Enum.map(alternatives, fn alt ->
      case Map.get(result_map, alt.id) do
        nil -> {alt, 0, 0.0}
        result -> result
      end
    end)
  end

  defp find_winner(results) do
    Enum.max_by(results, fn {_, count, _} -> count end)
  end
end
