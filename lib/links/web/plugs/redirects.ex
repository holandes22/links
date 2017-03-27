defmodule Links.Web.RedirectPlug do
  import Plug.Conn
  alias Links.Web.Router.Helpers

  def init(opts), do: opts

  def call(%{path_info: [], params: params, assigns: %{filters: filters}} = conn, _opts) when params == %{} and filters == %{}, do: conn
  def call(%{path_info: [], params: params} = conn, _opts) when params == %{} do
    to = Helpers.link_path(conn, :index, %{filters: conn.assigns.filters})
    conn
    |> Phoenix.Controller.redirect(to: to)
    |> halt()
  end
  def call(conn, _opts), do: conn

end
