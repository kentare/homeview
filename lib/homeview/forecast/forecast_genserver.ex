defmodule Homeview.ForecastGenserver do
  use GenServer
  @topic inspect(__MODULE__)
  @pubsub Homeview.PubSub

  defstruct local: nil, long: nil, tab: "local"

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    :timer.send_interval(1000 * 60 * 60, self(), :update_forecast)

    state = update_forecast(%{tab: "local"})

    {:ok, state}
  end

  def handle_call(:get_forecast, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:update_forecast, _from, state) do
    new_state = update_forecast(state)
    {:reply, new_state, new_state}
  end

  # I want to update tab state when the user clicks on the tab
  def handle_call({:update_tab, tab}, _from, state) do
    new_state = %{state | tab: tab}
    {:reply, new_state, new_state}
  end

  def update_tab(tab) do
    GenServer.call(__MODULE__, {:update_tab, tab})
  end

  defp update_forecast(state) do
    local = update_local_forecast()
    long = update_long_forecast()
    forecast = %__MODULE__{local: local, long: long, tab: state.tab}
    broadcast(:update_forecast, forecast)
    forecast
  end

  defp update_long_forecast() do
    html = Req.get!("https://www.yr.no/nn/innhald/1-2333502/meteogram.svg").body
    html
  end

  defp update_local_forecast() do
    html = Req.get!("https://www.yr.no/nn/innhald/1-2333502/card.html").body
    html
  end

  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  def broadcast(tag, forecast) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {tag, forecast})
  end

  def handle_info(:update_forecast, state) do
    forecast = update_forecast(state)
    broadcast(:update_forecast, forecast)
    {:noreply, forecast}
  end

  def get_forecast() do
    GenServer.call(__MODULE__, :get_forecast)
  end
end
