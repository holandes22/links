defmodule Links.Web.Plugs.StoreFiltersInSession do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_query_params(conn)

    case conn.params do
      %{"filters" => filters} ->
        conn
        |> put_session(:filters, Poison.encode!(filters))
        |> assign(:filters, filters)

      _ ->
        filters = current_filters(conn)
        conn
        |> put_session(:filters, filters)
        |> assign(:filters, Poison.decode!(filters))
    end
  end

  def current_filters(conn) do
    case get_session(conn, :filters) do
      nil     -> "{}"
      filters -> filters
    end
  end
end
