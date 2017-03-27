defmodule Links.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Links.Repo, []),
      supervisor(Links.Web.Endpoint, []),
    ]

    opts = [strategy: :one_for_one, name: Links.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
