defmodule Links.Repo.Migrations.AddUserIdToLink do
  use Ecto.Migration

  def change do
    alter table(:entries_links) do
      add :user_id, references(:users)
    end

  end
end
