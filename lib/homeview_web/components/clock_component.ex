defmodule HomeviewWeb.Clock do
  use HomeviewWeb, :live_component

  @impl true
  def mount(socket) do
    if connected?(socket), do: tick()
    socket = socket |> assign_time() |> assign(:id, "clock")
    {:ok, socket}
  end

  @impl true
  def update(%{action: :clock}, socket) do
    tick()
    {:ok, assign_time(socket)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full text-center mb-4 text-5xl max-w-full">
      <noscript>
        <div class="text-sm text-slate-500 flex gap-1 flex-wrap justify-center">
          Du har javascript avslått, så innholdet vil ikke oppdatere seg automatisk.
          <form action="">
            <button type="submit">Klikk her for å oppdatere</button>
          </form>
        </div>
        
        <div class="text-sm text-slate-500 underline mt-2">
          Sist oppdatert
        </div>
      </noscript>
       <%= @time %>
    </div>
    """
  end

  defp tick() do
    send_update_after(__MODULE__, %{id: "clock", action: :clock}, 250)
  end

  def assign_time(socket) do
    assign(socket, :time, get_time())
  end

  def get_time do
    Timex.now("Europe/Oslo")
    |> Timex.format!("{h24}:{m}:{s}")
  end
end
