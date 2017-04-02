defmodule Links.Web.AuthController do
  use Links.Web, :controller

  alias Links.Web.Strategy

  def index(conn, %{"provider" => provider}) do
    redirect conn, external: authorize_url!(provider)
  end

  def login(conn, _params) do
    render conn, "login.html"
  end

  def logout(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> clear_session()
    |> redirect(to: "/")
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    client = get_token!(provider, code)

    user_params = get_remote_user!(provider, client)

    user = Links.Entries.get_or_create_user(user_params)

    conn
    |> put_session(:current_user_id, user.id)
    |> redirect(to: "/")
  end

  defp authorize_url!("github"), do: Strategy.GitHub.authorize_url!(scope: "user:email")
  defp authorize_url!(_), do: raise "No matching provider available"

  defp get_token!("github", code),   do: Strategy.GitHub.get_token!(code: code)
  defp get_token!(_, _), do: raise "No matching provider available"

  defp get_remote_user!("github", client), do: Strategy.GitHub.get_user!(client)
  defp get_remote_user!(_, _), do: raise "No matching provider available"

end
