defmodule Links.Repo.Migrations.CreateLinks.Entries.Link do
  use Ecto.Migration

  def change do
    create table(:entries_links) do
      add :archived, :boolean, default: false, null: false
      add :notes, :string, default: ""
      add :link, :string, default: ""

      timestamps()
    end

  end
end
