defmodule HomeviewWeb.Clock do
  use HomeviewWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="w-full text-center mb-4 text-5xl max-w-full">
      <noscript>
        <div class="text-sm text-slate-500">
          Du har javascript avslått, så innholdet vil ikke oppdatere seg automatisk. trykk F5 for oppdatert innhold.
        </div>
        
        <div class="text-sm text-slate-500 underline">
          Sist oppdatert
        </div>
      </noscript>
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
