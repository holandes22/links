defmodule Links.Repo.Migrations.CreateLinks.Entries.User do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
