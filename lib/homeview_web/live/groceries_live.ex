defmodule HomeviewWeb.GroceriesLive do
  use HomeviewWeb, :live_view

  alias Homeview.Groceries.{Grocery}
  alias Homeview.Groceries

  @impl true
  def mount(_params, _session, socket) do
    if(connected?(socket)) do
      Groceries.subscribe()
    end

    add_form = to_form(Groceries.change_grocery(%Grocery{}))

    grocery_search = Groceries.search_groceries("")

    groceries =
      Groceries.list_groceries()
      |> Enum.reduce(
        %{should_buy: [], bought: []},
        fn grocery, acc ->
          if(is_nil(grocery.bought)) do
            %{acc | should_buy: [grocery | acc.should_buy]}
          else
            %{acc | bought: [grocery | acc.bought]}
          end
        end
      )

    {
      :ok,
      assign(socket, add_form: add_form)
      |> stream(:should_buy, groceries.should_buy)
      |> stream(:bought, groceries.bought)
      |> assign(:grocery_search, grocery_search)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="handleliste" class="w-full my-1">
      <.add_row add_form={@add_form} grocery_search={@grocery_search} />
      <h1 class="text-center text-xl mb-2 mt-6">Handleliste</h1>
      
      <div id="non-bought" phx-update="stream" class="flex flex-col gap-2 mt-5">
        <div :for={{dom_id, grocery} <- @streams.should_buy} id={dom_id}>
          <.grocery_row grocery_id={grocery.id} name={grocery.name} amount={grocery.amount} />
        </div>
      </div>
      
      <h1 class="text-center text-xl mb-2 mt-6">Kjøpt</h1>
      
      <div id="bought" phx-update="stream" class="flex flex-col gap-2">
        <div :for={{dom_id, grocery} <- @streams.bought} id={dom_id}>
          <.grocery_row
            grocery_id={grocery.id}
            action="undo"
            name={grocery.name}
            amount={grocery.amount}
          />
        </div>
      </div>
    </div>
    """
  end

  attr(:add_form, :map)
  attr(:grocery_search, :list)

  def add_row(assigns) do
    ~H"""
    <.form
      class="w-full pl-7"
      id="grocery-form"
      for={@add_form}
      phx-submit="save"
      phx-change="validate"
      phx-debounce="400"
    >
      <div class="flex w-full items-top gap-2 self-stretch">
        <div class="self-stretch grow">
          <.input
            field={@add_form[:name]}
            class="flex grow justify-between self-stretch w-full items-center shadow px-4"
            type="text"
            autocomplete="off"
            list="grocery_search"
          />
        </div>
        
        <button class="w-10 h-10 shadow bg-green-50 mt-2">
          <Heroicons.plus_circle />
        </button>
      </div>
    </.form>

    <datalist id="grocery_search">
      <option :for={{name, _count, _} <- @grocery_search} value={name}>
        <%= name %>
      </option>
    </datalist>
    """
  end

  attr(:action, :string, default: "buy")
  attr(:grocery_id, :integer, required: true)
  attr(:name, :string, required: true)
  attr(:amount, :integer, required: true)

  def grocery_row(assigns) do
    ~H"""
    <div class="flex w-full items-center gap-2">
      <Heroicons.x_mark
        class="w-5 text-red-500 cursor-pointer hover:text-white hover:bg-red-500"
        phx-click="update"
        phx-value-id={assigns.grocery_id}
        phx-value-action="delete"
      />
      <div class="flex grow justify-between self-stretch items-center gap-2 shadow px-4">
        <div>
          <%= String.capitalize(assigns.name) %>
        </div>
         <%= assigns.amount %>
      </div>
      
      <div class="flex flex-col gap-1 w-7">
        <button class="shadow p-1 bg-green-50 hover:bg-green-100">
          <Heroicons.plus
            phx-click="update"
            phx-value-id={assigns.grocery_id}
            phx-value-action="increment"
          />
        </button>
        
        <button class="shadow p-1 bg-red-50 hover:bg-red-100">
          <Heroicons.minus
            phx-click="update"
            phx-value-id={assigns.grocery_id}
            phx-value-action="decrement"
          />
        </button>
      </div>
      
      <button class="w-10 shadow self-stretch bg-yellow-50 hover:bg-yellow-100">
        <Heroicons.chevron_double_down
          :if={assigns.action === "buy"}
          phx-click="update"
          phx-value-id={assigns.grocery_id}
          phx-value-action="buy"
        />
        <Heroicons.chevron_double_up
          :if={assigns.action === "undo"}
          phx-click="update"
          phx-value-id={assigns.grocery_id}
          phx-value-action="undo"
        />
      </button>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"grocery" => grocery_params}, socket) do
    changeset =
      %Grocery{}
      |> Groceries.change_grocery(grocery_params)
      |> Map.put(:action, :validate)

    grocery_search = Groceries.search_groceries(grocery_params["name"])

    {:noreply, assign_form(socket, changeset) |> assign(:grocery_search, grocery_search)}
  end

  @impl true
  def handle_event("save", %{"grocery" => grocery_params}, socket) do
    grocery_params = Map.update!(grocery_params, "name", &String.downcase/1)

    case Groceries.create_grocery(grocery_params) do
      {:ok, _grocery} ->
        {:noreply,
         assign(socket, :add_form, to_form(Groceries.change_grocery(%Grocery{})))
         |> put_flash(:info, "Ny vare lagt til")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("update", %{"id" => id, "action" => action}, socket) do
    grocery = Groceries.get_grocery!(id)
    grocery_update(grocery, action, socket)
  end

  @impl true
  def handle_info({:create_grocery, grocery = %Grocery{}}, socket) do
    {:noreply, stream_insert(socket, :should_buy, grocery, at: 0)}
  end

  @impl true
  def handle_info({:delete_grocery, grocery = %Grocery{}}, socket) do
    socket =
      stream_delete(socket, :should_buy, grocery)
      |> stream_delete(:bought, grocery)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:buy_grocery, grocery = %Grocery{}}, socket) do
    socket =
      stream_delete(socket, :should_buy, grocery)
      |> stream_insert(:bought, grocery, at: 0)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:unbuy_grocery, grocery = %Grocery{}}, socket) do
    socket =
      stream_delete(socket, :bought, grocery)
      |> stream_insert(:should_buy, grocery, at: -1)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:update_grocery, grocery = %Grocery{}}, socket) do
    if(grocery.bought) do
      {:noreply, stream_insert(socket, :bought, grocery)}
    else
      {:noreply, stream_insert(socket, :should_buy, grocery)}
    end
  end

  def grocery_update(
        %Grocery{} = grocery,
        "increment",
        socket
      ) do
    Groceries.increment_grocery(grocery)
    {:noreply, socket}
  end

  def grocery_update(
        %Grocery{} = grocery,
        "decrement",
        socket
      ) do
    Groceries.decrement_grocery(grocery)
    {:noreply, socket}
  end

  def grocery_update(
        %Grocery{} = grocery,
        "buy",
        socket
      ) do
    Groceries.buy_grocery(grocery)
    {:noreply, socket}
  end

  def grocery_update(
        %Grocery{} = grocery,
        "undo",
        socket
      ) do
    Groceries.unbuy_grocery(grocery)
    {:noreply, socket}
  end

  def grocery_update(
        %Grocery{} = grocery,
        "delete",
        socket
      ) do
    Groceries.delete_grocery(grocery)
    {:noreply, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :add_form, to_form(changeset))
  end
end
