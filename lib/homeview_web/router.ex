defmodule HomeviewWeb.Router do
  use HomeviewWeb, :router

  import HomeviewWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {HomeviewWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
    plug(HomeviewWeb.UserIdentification)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  # Other scopes may use custom stacks.
  # scope "/api", HomeviewWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:homeview, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: HomeviewWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  scope "/", HomeviewWeb do
    pipe_through([:browser])

    live_session :normal,
      on_mount: [
        {HomeviewWeb.UserAuth, :mount_current_user},
        {HomeviewWeb.SaveRequestUri, :save_request_uri}
      ] do
      live("/", MainLive)
      live("/photo", PhotoLive)
      live("/transport", TransportLive)
      live("/weather", WeatherForecastLive)
    end
  end

  ## Authentication routes

  scope "/", HomeviewWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :require_authenticated_user,
      on_mount: [
        {HomeviewWeb.UserAuth, :ensure_authenticated},
        {HomeviewWeb.SaveRequestUri, :save_request_uri}
      ] do
      live("/users/settings", UserSettingsLive, :edit)
      live("/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email)
      live("/users/register", UserRegistrationLive, :new)

      # Chores
      live("/chores", ChoreLive.Index, :index)
      live("/chores/new", ChoreLive.Index, :new)
      live("/chores/:id/edit", ChoreLive.Index, :edit)

      live("/chores/:id", ChoreLive.Show, :show)
      live("/chores/:id/show/edit", ChoreLive.Show, :edit)

      # Chore history
      live("/chore_histories", ChoreHistoryLive.Index, :index)
      live("/chore_histories/new", ChoreHistoryLive.Index, :new)
      live("/chore_histories/:id/edit", ChoreHistoryLive.Index, :edit)

      live("/chore_histories/:id", ChoreHistoryLive.Show, :show)
      live("/chore_histories/:id/show/edit", ChoreHistoryLive.Show, :edit)

      live "/wishlist", WishlistLive, :index
      live "/wishlist/:id", WishlistLive, :show

      live("/groceries", GroceriesLive)
    end
  end

  scope "/", HomeviewWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    live_session :redirect_if_user_is_authenticated,
      on_mount: [
        {HomeviewWeb.UserAuth, :redirect_if_user_is_authenticated},
        {HomeviewWeb.SaveRequestUri, :save_request_uri}
      ] do
      live("/users/log_in", UserLoginLive, :new)
      live("/users/reset_password", UserForgotPasswordLive, :new)
      live("/users/reset_password/:token", UserResetPasswordLive, :edit)
      # live "/users/register", UserRegistrationLive, :new

      live "/polls", PollLive.Index, :index
      live "/polls/new", PollLive.Index, :new
      live "/polls/:id/edit", PollLive.Edit, :edit
      live "/polls/:id/vote", PollLive.Vote, :vote
      live "/polls/:id/results", PollLive.Results, :results
    end

    post("/users/log_in", UserSessionController, :create)
  end

  scope "/", HomeviewWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)

    live_session :current_user,
      on_mount: [
        {HomeviewWeb.UserAuth, :mount_current_user},
        {HomeviewWeb.SaveRequestUri, :save_request_uri}
      ] do
      live("/users/confirm/:token", UserConfirmationLive, :edit)
      live("/users/confirm", UserConfirmationInstructionsLive, :new)
    end
  end
end
