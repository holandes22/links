defmodule Links.Repo.Migrations.AddFavoriteField do
  use Ecto.Migration

  def change do
    alter table(:entries_links) do
      add :favorite, :boolean, default: false, null: false
    end
  end
end
