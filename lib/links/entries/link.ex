defmodule Links.Entries.Link do
  use Ecto.Schema

  schema "entries_links" do
    field :archived, :boolean, default: false
    field :notes, :string, default: ""
    field :link, :string, default: ""
    many_to_many :tags, Links.Entries.Tag,
                 join_through: "entries_links_tags",
                 on_replace: :delete,
                 # delete_all behavior will only remove from the join table, and not the tags
                 # https://hexdocs.pm/ecto/Ecto.Schema.html#many_to_many/3-removing-data
                 on_delete: :delete_all
    field :csv_tags, :string, virtual: true

    timestamps()
  end
end
