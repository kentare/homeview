defmodule Homeview.GeneratePubsub do
  def subscribe() do
    Phoenix.PubSub.subscribe(Homeview.PubSub, "poll_updated")
  end

  def broadcast_updated() do
    Phoenix.PubSub.broadcast(Homeview.PubSub, "poll_updated", {:poll_updated})
  end
end
