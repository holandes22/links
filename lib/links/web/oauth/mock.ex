defmodule Links.Oauth.Mock do

  def authorize_url!(_params) do
    "http://localhost:9988"
  end

  def get_token!(_params) do
    %{}
  end

  def get_user!(_client) do
    %{email: "eder@caed-nua.pillars"}
  end

end
