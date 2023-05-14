defmodule HomeviewWeb.CustomComponents do
  use Phoenix.Component

  attr :active, :boolean, default: false
  slot :inner_block
  attr :href, :string
  attr :rest, :global

  def sidebar_link(assigns) do
    ~H"""
    <.link
      {@rest}
      href={@href}
      class={"w-20 h-20 px-3 py-6 flex-grow flex justify-center items-center " <> (if @active, do: "bg-slate-300 shadow-inner", else: "")}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  def tram_icon(assigns) do
    ~H"""
    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" class="h-full w-full">
      <path
        fill-rule="evenodd"
        clip-rule="evenodd"
        d="M12.4113 5.41581L10.8273 6.99977H2.8673C2.36964 6.99977 1.94772 7.3657 1.87735 7.85835L1.07071 13.5048C1.0262 13.8164 1.13099 14.1308 1.35355 14.3533L2.70711 15.7069C2.89464 15.8944 3.149 15.9998 3.41421 15.9998H4.75C4.88807 15.9998 5 16.1117 5 16.2498V16.4998C5 16.7759 5.22386 16.9998 5.5 16.9998H9.5C9.77614 16.9998 10 16.7759 10 16.4998V16.2498C10 16.1117 10.1119 15.9998 10.25 15.9998H13.75C13.8881 15.9998 14 16.1117 14 16.2498V16.4998C14 16.7759 14.2239 16.9998 14.5 16.9998H18.5C18.7761 16.9998 19 16.7759 19 16.4998V16.2498C19 16.1117 19.1119 15.9998 19.25 15.9998H20.5858C20.851 15.9998 21.1054 15.8944 21.2929 15.7069L22.6464 14.3533C22.869 14.1308 22.9738 13.8164 22.9293 13.5048L22.1227 7.85835C22.0523 7.3657 21.6304 6.99977 21.1327 6.99977H12.2415L13.4725 5.76874C13.6678 5.57344 13.6678 5.25677 13.4724 5.06153L11.5816 3.1718C11.4839 3.07422 11.3257 3.07425 11.2281 3.17186L10.8745 3.52546C10.7768 3.62309 10.7768 3.78138 10.8745 3.87901L12.4113 5.41581ZM15 8.99977H9V11.9998H15V8.99977ZM16 8.99977H19.5C19.7761 8.99977 20 9.22363 20 9.49977V11.9998H16V8.99977ZM8 8.99977H4.5C4.22386 8.99977 4 9.22363 4 9.49977V11.9998H8V8.99977Z"
        fill="currentColor"
      >
      </path>
      
      <path
        d="M1 17.25C1 17.1119 1.11193 17 1.25 17H22.75C22.8881 17 23 17.1119 23 17.25V17.75C23 17.8881 22.8881 18 22.75 18H1.25C1.11193 18 1 17.8881 1 17.75V17.25Z"
        fill="currentColor"
      >
      </path>
    </svg>
    """
  end

  attr :rest, :global

  def subway_icon(assigns) do
    ~H"""
    <svg
      viewBox="0 0 24 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      class="h-full w-full"
      {@rest}
    >
      <path
        fill-rule="evenodd"
        clip-rule="evenodd"
        d="M12 22C17.5228 22 22 17.5228 22 12C22 6.47715 17.5228 2 12 2C6.47715 2 2 6.47715 2 12C2 17.5228 6.47715 22 12 22ZM7.5 8C7.22386 8 7 8.22386 7 8.5V9.5C7 9.77614 7.22386 10 7.5 10H11V17.5C11 17.7761 11.2239 18 11.5 18H12.5C12.7761 18 13 17.7761 13 17.5V10H16.5C16.7761 10 17 9.77614 17 9.5V8.5C17 8.22386 16.7761 8 16.5 8H7.5Z"
        fill="currentColor"
      >
      </path>
    </svg>
    """
  end

  def bus_icon(assigns) do
    ~H"""
    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" class="h-full w-full">
      <path
        fill-rule="evenodd"
        clip-rule="evenodd"
        d="M23 8C23 7.44772 22.5523 7 22 7H2C1.44772 7 1 7.44772 1 8V16.5C1 16.7761 1.22386 17 1.5 17H2.5C2.77614 17 2.99563 16.7745 3.04113 16.5021C3.2783 15.0822 4.51277 14 6 14C7.48723 14 8.7217 15.0822 8.95887 16.5021C9.00437 16.7745 9.22386 17 9.5 17H14.5C14.7761 17 14.9956 16.7745 15.0411 16.5021C15.2783 15.0822 16.5128 14 18 14C19.4872 14 20.7217 15.0822 20.9589 16.5021C21.0044 16.7745 21.2239 17 21.5 17H22.5C22.7761 17 23 16.7761 23 16.5V8ZM9 9.5C9 9.22386 9.22386 9 9.5 9H14.5C14.7761 9 15 9.22386 15 9.5V11.5C15 11.7761 14.7761 12 14.5 12H9.5C9.22386 12 9 11.7761 9 11.5V9.5ZM8 9.5C8 9.22386 7.77614 9 7.5 9H3.5C3.22386 9 3 9.22386 3 9.5V11.5C3 11.7761 3.22386 12 3.5 12H7.5C7.77614 12 8 11.7761 8 11.5V9.5ZM16 9.5C16 9.22386 16.2239 9 16.5 9H20.5C20.7761 9 21 9.22386 21 9.5V11.5C21 11.7761 20.7761 12 20.5 12H16.5C16.2239 12 16 11.7761 16 11.5V9.5Z"
        fill="currentColor"
      >
      </path>
      
      <path
        d="M18 19C19.1046 19 20 18.1046 20 17C20 15.8954 19.1046 15 18 15C16.8954 15 16 15.8954 16 17C16 18.1046 16.8954 19 18 19Z"
        fill="currentColor"
      >
      </path>
      
      <path
        d="M8 17C8 18.1046 7.10457 19 6 19C4.89543 19 4 18.1046 4 17C4 15.8954 4.89543 15 6 15C7.10457 15 8 15.8954 8 17Z"
        fill="currentColor"
      >
      </path>
    </svg>
    """
  end
end
