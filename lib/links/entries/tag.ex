defmodule Links.Entries.Tag do
  use Ecto.Schema

  alias Links.Web.Validator

  schema "entries_tags" do
    field :name, :string
  end

end
