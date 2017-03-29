defmodule Links.Web.Router do
  use Links.Web, :router
  alias Links.Web.Plugs

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Plugs.CurrentUser
    plug Plugs.StoreFiltersInSession
    plug Plugs.RedirectIfFilters
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Links.Web do
    pipe_through :browser

    resources "/", LinkController, except: [:show]
    get "/clear-filters", LinkController, :clear_filters
  end

end
