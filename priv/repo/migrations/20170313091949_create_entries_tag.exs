defmodule Links.Repo.Migrations.CreateLinks.Entries.Tag do
  use Ecto.Migration

  def change do
    create table(:entries_tags) do
      add :name, :string
    end

    create unique_index(:entries_tags, [:name])
  end
end
