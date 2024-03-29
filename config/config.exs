# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :links,
  ecto_repos: [Links.Repo]

# Configures the endpoint
config :links, Links.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WZbOY6rK3SxTKGv7Gd9YWPJ8TuL67UoEFAx455HNc2yABIVZimF6voRpfHGcob6h",
  render_errors: [view: Links.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Links.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :links, GitHub,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
  redirect_uri: System.get_env("GITHUB_REDIRECT_URI")

config :links, Google,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
  redirect_uri: System.get_env("GOOGLE_REDIRECT_URI")


config :links, :github_strategy, Links.Oauth.GitHub
config :links, :google_strategy, Links.Oauth.Google


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
