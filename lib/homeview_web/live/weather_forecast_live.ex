defmodule HomeviewWeb.WeatherForecastLive do
  use HomeviewWeb, :live_view

  alias HomeviewWeb.Clock

  def mount(_params, _session, socket) do
    if(connected?(socket)) do
      :timer.send_interval(1000 * 60 * 60, self(), :update_forecast)
      :timer.send_interval(1000, self(), :update_time)
    end

    {:ok,
     assign(socket,
       forecast: get_forecast(),
       time: Clock.get_time()
     )}
  end

  def render(assigns) do
    ~H"""
    <.live_component assigns id="clock" module={HomeviewWeb.Clock} time={@time} />
    <div class="px-2 w-full overflow-x-auto center-child-svg">
      <%= raw(@forecast) %>
    </div>
    """
  end

  def handle_info(:update_time, socket) do
    {:noreply, Clock.assign_time(socket)}
  end

  def handle_info(:update_forecast, socket) do
    {:noreply,
     assign(socket,
       forecast: get_forecast()
     )}
  end

  defp get_forecast() do
    html = Req.get!("https://www.yr.no/nn/innhald/1-2333502/meteogram.svg").body
    html
  end
end
