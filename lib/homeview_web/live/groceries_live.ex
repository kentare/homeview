defmodule HomeviewWeb.GroceriesLive do
  use HomeviewWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <div id="handleliste" class="w-full my-1">
      <h1 class="text-center text-xl mb-2">Handleliste</h1>
        <div id="non-bought" class="flex flex-col gap-2">
      <.add_row />
        <.grocery_row />
        <.grocery_row />
        <.grocery_row />
        </div>
      <h1 class="text-center text-xl my-2">Kjøpt</h1>
        <div id="bought" class="flex flex-col gap-2">
        <.grocery_row action="undo" />
        <.grocery_row action="undo" />
        <.grocery_row action="undo" />
        </div>
      </div>
    """
  end

  def add_row(assigns) do
    ~H"""
              <div class="flex w-full items-center gap-2 mb-2">
                <input class="flex grow justify-between self-stretch items-center gap-2 shadow px-4" label="add" type="text" />
    
              <button class="w-[4.7rem] shadow self-stretch bg-green-50   ">
                  <Heroicons.plus />
              </button>
              </div>
    """
  end

  attr(:action, :string, default: "buy")

  def grocery_row(assigns) do
    ~H"""
              <div class="flex w-full items-center gap-2">
                <div class="flex grow justify-between self-stretch items-center gap-2 shadow px-4">
                  <div>item</div>
    
                  <div>2</div>
                </div>
    
                <div class="flex flex-col gap-1 w-7">
                  <button class="shadow p-1 bg-green-50"><Heroicons.plus /></button>
    
                  <button class="shadow p-1 bg-red-50">
                  <Heroicons.minus />
                  </button>
                </div>
              <button class="w-10 shadow self-stretch bg-yellow-50">
                  <Heroicons.chevron_double_down :if={assigns.action === "buy"} />
                  <Heroicons.chevron_double_up :if={assigns.action === "undo"} />
              </button>
              </div>
    """
  end
end
