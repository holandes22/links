defmodule Links.Web.Plugs.CurrentUser do
  import Plug.Conn

  def init(opts), do: opts

  def call(%{assings: %{current_user: _user}} = conn, _opts), do: conn
  def call(conn, _opts) do
    user = Links.Repo.get(Links.Entries.User, 1)
    assign(conn, :current_user, user)
  end
end
