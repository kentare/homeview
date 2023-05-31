defmodule HomeviewWeb.ChoreLive.SnailComponent do
  use HomeviewWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id="chores" phx-update="stream" class="flex flex-col gap-6 my-6 divide-y-2">
      <div :for={{id, chore} <- @chores} id={id} class="flex pt-6 items-start flex-col justify-start">
        <div class="w-full flex">
          <div class="w-full flex flex-col">
            <div class="flex justify-between w-full ">
              <div class="text-xl ml-4 "><%= chore.name %></div>
              
              <div class="flex gap-1">
                <div class="flex items-center gap-1 mr-4">
                  <%= chore.time_interval %>
                  <div class="h-5 w-5"><Heroicons.calendar_days /></div>
                </div>
                
                <div class="flex items-center mr-4 gap-1">
                  <%= chore.countdown %>
                  <div class="h-5 w-5"><Heroicons.clock /></div>
                </div>
              </div>
            </div>
            
            <div
              phx-click="do_task"
              phx-value-id={chore.id}
              class="flex w-full mt-2 p-2 bg-slate-200 hover:bg-slate-300 rounded-full cursor-pointer items-center "
            >
              <div class=" rounded-full h-10  w-full relative top-0 left-0">
                <img
                  phx-click="do_task"
                  phx-value-id={chore.id}
                  style={
                    cond do
                      chore.countdown == chore.time_interval ->
                        "left: -3%;"

                      chore.countdown > 0 ->
                        "left: " <>
                          Float.to_string(Kernel.min(Kernel.max(chore.fill_percent - 7, 0.0), 100)) <>
                          "%;"

                      true ->
                        "left: 93%;"
                    end
                  }
                  class={"absolute z-10 h-[3.4rem] drop-shadow scale-x-[-1] translate-y-[-25%] hover:scale-x-[-1.2] hover:scale-y-[1.2] transition-all duration-200
               #{if Map.has_key?(chore, :class), do: chore.class}
              "}
                  src={snail_image(chore.name)}
                />
                <%!-- background-color: hsl(" <> Float.to_string((100 - chore.fill_percent) * 100 / 45)  <> ", 100%, 70%) --%>
                <%!-- mid_part =  "hsl(" <> color_string <> ", 100%, 70%) " <> Float.to_string(color + 1) <> "%, " <> "rgba(255,255,255,0.1) " <> color_string <> "%, hsl(" <> color_string <> ", 100%, 70%) " <> Float.to_string(color + 1) <> "%" --%>
                <div
                  style={
                    if chore.countdown > 0 do
                      color = (100 - chore.fill_percent) * 100 / 70
                      color_string = Float.to_string(color)
                      mid_color = (100 + color) / 2

                      left_color =
                        cond do
                          chore.fill_percent > 75 -> Float.to_string(mid_color)
                          true -> "100"
                        end

                      mid_part =
                        "hsl(" <> Float.to_string(mid_color) <> ", 100%, 70%) " <> color_string <> "%"

                      left_part = "hsl(" <> left_color <> ", 100%, 70%) 0%"

                      "width: " <>
                        Float.to_string(Kernel.min(Kernel.max(chore.fill_percent, 0.0), 100)) <>
                        "%;" <>
                        "background: linear-gradient(90deg, " <>
                        left_part <>
                        ", " <> mid_part <> ", hsl(" <> color_string <> ", 100%, 70%) 100%);
                "
                    else
                      "width: 100%; background-color: hsl(0, 100%, 70%)"
                    end
                  }
                  class="absolute overflow-hidden h-full rounded-full transition-snail-track duration-1000"
                >
                </div>
                
                <div class="absolute gap-5 h-full w-full flex justify-between px-4 items-center font-semibold">
                  <div></div>
                </div>
              </div>
            </div>
          </div>
          
          <div class="flex flex-col items-center ">
            <div class="h-7"></div>
            
            <div class="flex flex-grow items-center justify-center ml-7 cursor-pointer gap-5">
              <div class="w-6 h-6 hover:bg-slate-100 rounded-full">
                <.link
                  phx-click={JS.push("delete_last_history", value: %{id: chore.id})}
                  data-confirm="Vil du angre gjøremålet?"
                >
                  <Heroicons.arrow_uturn_left />
                </.link>
              </div>
              
              <div class="w-6 h-6 hover:bg-slate-100 rounded-full">
                <.link patch={~p"/chores/#{chore}/edit"}>
                  <Heroicons.cog_6_tooth />
                </.link>
              </div>
              
              <div class="w-6 h-6 hover:bg-slate-100 rounded-full">
                <.link
                  phx-click={JS.push("delete", value: %{id: chore.id}) |> hide("##{id}")}
                  data-confirm="Vil du slette gjøremålet?"
                >
                  <Heroicons.trash />
                </.link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp snail_image(name) do
    data =
      name
      |> String.to_charlist()
      |> Enum.reduce(0, fn char, acc ->
        acc + char
      end)
      |> rem(9)
      |> Kernel.+(1)
      |> Integer.to_string()

    "/images/snails/" <> data <> ".svg"
  end
end
