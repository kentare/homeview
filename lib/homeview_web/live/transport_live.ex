defmodule HomeviewWeb.TransportLive do
  use HomeviewWeb, :live_view

  alias Homeview.Transport.Stops
  alias HomeviewWeb.Clock

  def mount(_params, _session, socket) do
    if(connected?(socket)) do
      :timer.send_interval(15000, self(), :tick)
      :timer.send_interval(1000, self(), :update_time)
    end

    {:ok,
     assign(socket,
       stops: get_filtered_data(),
       time: Clock.get_time()
     )}
  end

  def render(assigns) do
    ~H"""
    <%!-- <%= live_component(HomeviewWeb.Clock, id: :clock) %> --%>
    <.live_component assigns id="clock" module={HomeviewWeb.Clock} time={@time} />
    <div class="bg-slate-100 rounded-xl px-8 py-5 md:min-w-[42rem] min-w-[80vw]">
      <%!-- <div class="flex md:gap-5 gap-1 h-10 items-center mb-10">
        <.subway_icon />
        <.tram_icon />
        <.bus_icon />
      </div> --%>
      <div class=" divide-y divide-slate-400/25 ">
        <.table_row
          :for={stop <- @stops}
          number={stop.number}
          destination={stop.displayName}
          departure={stop.expectedDepartureTime}
        />
      </div>
    </div>
    """
  end

  attr :number, :string
  attr :destination, :string
  attr :departure, :string

  def table_row(assigns) do
    ~H"""
    <div class="flex justify-between py-2 gap-10   ">
      <div class="flex items-center gap-3">
        <div class={"px-5 py-2 w-16 flex justify-center rounded-2xl text-white text-xl font-bold " <> if @number == "3", do: "bg-orange-500", else: "bg-blue-500"}>
          <%= @number %>
        </div>
        <div class="text-xl">
          <%= @destination %>
        </div>
      </div>
      <div class="flex justify-end gap-5 items-center">
        <div class="text-xl font-bold">
          <%= @departure %>
        </div>

        <div class="w-6 h-6 text-slate-300">
          <.subway_icon :if={@number == "3"} />
          <.tram_icon :if={@number == "13"} />
        </div>
      </div>
    </div>
    """
  end

  # def format_time(time) do
  #   time
  #   |> DateTime.from_iso8601()
  #   |> DateTime.to_unix(:second)
  #   |> Timex.format!("{h}:{m}")
  # end

  # 2023-05-13T17:08:00+02:00
  # if under one minute return "Nå"
  # if under 10 minutes return "x min"
  # if over 10 minutes return "HH:MM"

  defp get_filtered_data() do
    Stops.fetch_data()
    |> Stops.extract_data_points()
    |> Stops.filter_by_platform_numbers(["1", "3"])
  end

  def handle_info(:update_time, socket) do
    {:noreply, Clock.assign_time(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply,
     assign(socket,
       stops: get_filtered_data()
     )}
  end
end
