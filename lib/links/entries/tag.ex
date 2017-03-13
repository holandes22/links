defmodule Links.Entries.Tag do
  use Ecto.Schema

  schema "entries_tags" do
    field :name, :string
  end
end
