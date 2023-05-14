defmodule HomeviewWeb.MainLive do
  use HomeviewWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, hey: "yo")}
  end

  def render(assigns) do
    ~H"""
    <div class="text-8xl">Heisann.</div>
    """
  end
end
