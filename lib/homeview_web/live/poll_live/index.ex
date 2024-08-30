defmodule HomeviewWeb.PollLive.Index do
  alias Homeview.Accounts.AnonymousUser
  use HomeviewWeb, :live_view

  alias Homeview.Polls
  alias Homeview.Polls.Poll
  alias Homeview.Accounts

  @impl true
  def mount(_params, session, socket) do
    ready_polls = Polls.list_ready_polls()
    not_ready_polls = Polls.list_not_ready_polls()
    socket = socket |> cookie_assigns(session)

    changeset =
      Polls.change_poll(%Poll{
        created_by_id: socket.assigns.current_user_id
      })

    {:ok,
     socket
     |> assign(ready_polls: ready_polls, not_ready_polls: not_ready_polls)
     |> assign(new_poll: to_form(changeset))
     |> assign(
       user_form:
         to_form(
           Accounts.change_anonymous_user(%Accounts.AnonymousUser{}, %{
             name: socket.assigns.current_name
           })
         )
     )
     |> cookie_assigns(session)}
  end

  @impl true
  def handle_event("save", %{"poll" => poll_params}, socket) do
    case Polls.create_poll(poll_params) do
      {:ok, _poll} ->
        {:noreply,
         socket
         |> put_flash(:info, "Poll created successfully")
         |> assign(new_poll: to_form(Polls.change_poll(%Poll{})))
         |> assign(not_ready_polls: Polls.list_not_ready_polls())}

      {:error, %Ecto.Changeset{} = changeset} ->
        dbg(changeset)
        {:noreply, assign(socket, new_poll: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("validate", %{"poll" => poll_params}, socket) do
    changeset =
      %Poll{}
      |> Polls.change_poll(poll_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, new_poll: to_form(changeset))}
  end

  def handle_event("change_name", %{"anonymous_user" => name_params}, socket) do
    name = name_params["name"]

    changeset =
      Accounts.change_anonymous_user(%AnonymousUser{user_id: socket.assigns.current_user_id}, %{
        name: name
      })

    if(changeset.valid?) do
      update_anonymous_user_name(socket, name)
    else
      IO.inspect("hey")
      {:noreply, assign(socket, user_form: to_form(changeset) |> Map.put(:action, :validate))}
    end
  end

  @impl true
  def handle_event("delete_poll", %{"id" => id}, socket) do
    poll = Polls.get_poll!(id)
    {:ok, _} = Polls.delete_poll(poll)

    ready_polls = Polls.list_ready_polls()
    not_ready_polls = Polls.list_not_ready_polls()

    {:noreply,
     assign(socket, ready_polls: ready_polls, not_ready_polls: not_ready_polls)
     |> put_flash(:info, "Påll er borte for alltid...")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Poll")
    |> assign(:poll, Polls.get_poll!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Poll")
    |> assign(:poll, %Poll{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Polls")
    |> assign(:poll, nil)
  end

  defp update_anonymous_user_name(socket, name) do
    case Homeview.Accounts.update_anonymous_user_name(socket.assigns.current_user_id, name) do
      {:ok, _} ->
        poll_changeset =
          Polls.change_poll(%Poll{}, %{
            created_by: name,
            text: socket.assigns.new_poll.source.changes[:text] || nil
          })

        {:noreply,
         socket
         |> put_flash(:info, "Name changed successfully")
         |> assign(current_name: name)
         |> assign(
           user_form:
             to_form(Accounts.change_anonymous_user(%Accounts.AnonymousUser{}, %{name: name}))
         )
         |> assign(new_poll: to_form(poll_changeset))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, user_form: to_form(changeset))}
    end
  end
end
