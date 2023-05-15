defmodule HomeviewWeb.Clock do
  use HomeviewWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="w-full text-center mb-4 text-5xl max-w-full">
      <%= @time %>
    </div>
    """
  end

  def assign_time(socket) do
    assign(socket, time: get_time())
  end

  def get_time do
    Timex.now("Europe/Oslo")
    |> Timex.format!("{h24}:{m}:{s}")
  end
end
