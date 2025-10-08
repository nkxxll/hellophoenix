defmodule HellophoenixWeb.Router do
  use HellophoenixWeb, :router

  import HellophoenixWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HellophoenixWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
    plug :fetch_current_cart
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/bytes", HellophoenixWeb do
    pipe_through :browser

    get "/", BytesController, :direct
  end

  scope "/", HellophoenixWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/hello", HelloController, :index
    get "/hello/:messenger", HelloController, :show

    live_session :search,
      on_mount: [{HellophoenixWeb.UserAuth, :mount_current_scope}] do
      live "/items", ItemLive.Index, :index
      live "/items/new", ItemLive.Form, :new
      live "/items/:id", ItemLive.Show, :show
      live "/items/:id/edit", ItemLive.Form, :edit
    end

    # resources "/users", UserController, only: [:index, :new, :create, :show]
    resources "/products", ProductController
  end

  # Other scopes may use custom stacks.
  # scope "/api", HellophoenixWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:hellophoenix, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HellophoenixWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", HellophoenixWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
  end

  scope "/", HellophoenixWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm-email/:token", UserSettingsController, :confirm_email
  end

  scope "/", HellophoenixWeb do
    pipe_through [:browser]

    get "/users/log-in", UserSessionController, :new
    get "/users/log-in/:token", UserSessionController, :confirm
    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  scope "/", HellophoenixWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/cart_items", CartItemController, only: [:create, :delete]

    get "/cart", CartController, :show
    put "/cart", CartController, :update

    resources "/orders", OrderController, only: [:create, :show]
  end

  alias Hellophoenix.ShoppingCart

  defp fetch_current_cart(%{assigns: %{current_scope: scope}} = conn, _opts)
       when not is_nil(scope) do
    if cart = ShoppingCart.get_cart(scope) do
      assign(conn, :cart, cart)
    else
      {:ok, new_cart} = ShoppingCart.create_cart(scope, %{})
      assign(conn, :cart, new_cart)
    end
  end

  defp fetch_current_cart(conn, _opts), do: conn
end
