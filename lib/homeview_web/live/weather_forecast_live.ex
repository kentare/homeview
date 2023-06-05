defmodule HomeviewWeb.WeatherForecastLive do
  use HomeviewWeb, :live_view
  alias Homeview.ForecastGenserver

  @impl true
  def mount(_params, _session, socket) do
    if(connected?(socket)) do
      ForecastGenserver.subscribe()
    end

    %ForecastGenserver{local: local, long: long} = ForecastGenserver.get_forecast()

    {:ok, assign(socket, :local, local) |> assign(:long, long)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-2 w-full overflow-x-auto center-child-svg">
      <%= raw(@local) %>
      <div class="my-6"></div>
      <%= raw(@long) %>
    </div>
    """
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
