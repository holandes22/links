defmodule Links.Entries.User do
  use Ecto.Schema

  schema "users" do
    field :email, :string
    has_many :links, Links.Entries.Link

    timestamps()
  end
end
