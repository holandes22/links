defmodule Links.Oauth.Google do
  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  defp config do
    [strategy: __MODULE__,
     site: "https://accounts.google.com",
     authorize_url: "/o/oauth2/auth",
     token_url: "/o/oauth2/token"]
  end

  # Public API

  def client do
    :links
    |> Application.get_env(Google)
    |> Keyword.merge(config())
    |> OAuth2.Client.new()
  end

  def authorize_url!(params \\ []) do
    OAuth2.Client.authorize_url!(client(), params)
  end

  def get_token!(params \\ []) do
    OAuth2.Client.get_token!(client(), Keyword.merge(params, client_secret: client().client_secret))
  end

  def get_user!(client) do
    %{body: %{"email" => email}} = OAuth2.Client.get!(client, "https://www.googleapis.com/plus/v1/people/me/openIdConnect")

    %{email: email}
  end

  # Strategy callbacks

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end
end
