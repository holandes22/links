defmodule Links.Entries.Tag do
  use Ecto.Schema

  schema "entries_tags" do
    field :name, :string
    many_to_many :links, Links.Entries.Link, join_through: "entries_links_tags"
  end

end
