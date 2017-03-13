defmodule Links.Repo.Migrations.AddTagsRelation do
  use Ecto.Migration

  def change do
    create table(:entries_links_tags, primary_key: false) do
      add :link_id, references(:entries_links)
      add :tag_id, references(:entries_tags)
    end

  end
end
