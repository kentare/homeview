defmodule HomeviewWeb.PhotoLive do
  use HomeviewWeb, :live_view

  alias Homeview.Chores

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :chore_histories, Chores.list_chore_histories())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-[85vh]">
      <iframe
        src="http://localhost:1401"
        class="w-full flex-grow border-2 border-gray-300 rounded-lg"
        title="Local Development Server"
      >
      </iframe>
    </div>
    """
  end
end
