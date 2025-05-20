defmodule IgIntranetWeb.Router do
  @moduledoc """
  Router module.
  """
  use IgIntranetWeb, :router

  import IgIntranetWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {IgIntranetWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug IgIntranetWeb.Plugs.Locale
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", IgIntranetWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/same_home_but_different", PageController, :home

    # Routes de la live intranet_conversations
    live "/intranet_conversations", IntranetConversationLive.Index, :index
    live "/intranet_conversations/new", IntranetConversationLive.Index, :new
    live "/intranet_conversations/:id/edit", IntranetConversationLive.Index, :edit
    live "/intranet_conversations/:id", IntranetConversationLive.Show, :show
    live "/intranet_conversations/:id/show/edit", IntranetConversationLive.Show, :edit

    # Routes de la live intranet_messages
    live "/intranet_messages", IntranetMessageLive.Index, :index
    live "/intranet_messages/new", IntranetMessageLive.Index, :new
    live "/intranet_messages/:id/edit", IntranetMessageLive.Index, :edit
    live "/intranet_messages/:id", IntranetMessageLive.Show, :show
    live "/intranet_messages/:id/show/edit", IntranetMessageLive.Show, :edit

    # Routes de la live intranet_chat
    live "/intranet_chat", IntranetChatLive.Index, :index
    live "/intranet_chat/new", IntranetChatLive.Index, :new
  end

  # Other scopes may use custom stacks.
  # scope "/api", IgIntranetWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ig_intranet, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: IgIntranetWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", IgIntranetWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{IgIntranetWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", IgIntranetWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{IgIntranetWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", IgIntranetWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{IgIntranetWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
