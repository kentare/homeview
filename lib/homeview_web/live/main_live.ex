defmodule HomeviewWeb.MainLive do
  use HomeviewWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, hey: "yo")}
  end

  def render(assigns) do
    ~H"""
    <div class="flex items-end gap-2 flex-wrap justify-center">
      <div class="text-8xl">
        Heisann.
      </div>
      <div class="flex flex-column">
        <%= if !@current_user do %>
          <.internal_button patch={~p"/users/log_in"}>
            Logg inn
          </.internal_button>
        <% else %>
          <.internal_button patch={~p"/users/settings"}>
            Instillinger
          </.internal_button>
          <.internal_button method="delete" href={~p"/users/log_out"}>
            Logg ut
          </.internal_button>
        <% end %>
      </div>
    </div>
    """
  end

  slot :inner_block
  attr :rest, :global, include: [:method, :href, :patch]

  defp internal_button(assigns) do
    ~H"""
    <.link
      type="button"
      class="py-2.5 px-5 mr-2 mb-2 text-sm font-medium text-gray-900 focus:outline-none bg-white rounded-lg border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-700 dark:bg-gray-800 dark:text-gray-400 dark:border-gray-600 dark:hover:text-white dark:hover:bg-gray-700"
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end
end
