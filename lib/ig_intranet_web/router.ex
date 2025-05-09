defmodule IgIntranetWeb.Router do
  @moduledoc """
  Router module.
  """
  use IgIntranetWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {IgIntranetWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
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
end
