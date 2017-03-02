defmodule Links.Entries.Link do
  use Ecto.Schema

  schema "entries_links" do
    field :archived, :boolean, default: false
    field :notes, :string, default: ""
    field :link, :string, default: ""

    timestamps()
  end
end
