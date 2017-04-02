defmodule Links.Web.Plugs.CurrentUser do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :current_user_id) do
      nil ->
        assign(conn, :current_user, :anonymous)
      id ->
        assign(conn, :current_user, Links.Entries.get_user!(id))

    end
  end
end
