defmodule HomeviewWeb.WeatherForecastLive do
  use HomeviewWeb, :live_view
  alias Homeview.ForecastGenserver

  @impl true
  def mount(_params, _session, socket) do
    if(connected?(socket)) do
      ForecastGenserver.subscribe()
    end

    %ForecastGenserver{local: local, long: long} = ForecastGenserver.get_forecast()

    {:ok, assign(socket, :local, local) |> assign(:long, long) |> assign(:show, :local)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
    <.show_button show={@show} />
    <div :if={@show == :local}
    class="px-2 w-full h-full overflow-x-auto center-child-svg"
    >
      <iframe srcdoc={@local} class="min-h-[50vh] w-full"></iframe>
      </div>
    <div :if={@show == :long} class="px-2 w-full h-full overflow-x-auto center-child-svg">
      <%= raw(@long) %>
      </div>
    </div>
    """
  end

  # :local
  attr(:show, :atom)

  def show_button(assigns) do
    ~H"""

    <div class="flex justify-center">
    <div class="flex gap-1 p-1 rounded-md w-64 bg-slate-200">
    <.single_show_button active={@show == :local} on_click="show_local">
    Show local
    </.single_show_button>
    <.single_show_button active={@show == :long} on_click="show_long">
    Show long
    </.single_show_button>
    </div>
    </div>
    """
  end

  attr(:active, :boolean, required: true)
  attr(:on_click, :string, required: true)
  slot(:inner_block, required: true)

  def single_show_button(assigns) do
    ~H"""
    <button class={"h-9 px-2 grow #{if assigns.active do
    "rounded-md bg-white text-sky-600"
    end}"}  phx-click={assigns.on_click}>
        <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @impl true
  def handle_event("show_local", _, socket) do
    {:noreply, assign(socket, :show, :local)}
  end

  @impl true
  def handle_event("show_long", _, socket) do
    {:noreply, assign(socket, :show, :long)}
  end

  @impl true
  def handle_info(
        {:update_forecast, %ForecastGenserver{:local => local, :long => long}},
        socket
      ) do
    {:noreply, assign(socket, :local, local) |> assign(:long, long)}
  end

  # defp get_forecast() do
  #   html = Req.get!("https://www.yr.no/nn/innhald/1-2333502/meteogram.svg").body
  #   html
  # end
end
