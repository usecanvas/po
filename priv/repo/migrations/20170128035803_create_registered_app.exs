defmodule Po.Repo.Migrations.CreateRegisteredApp do
  use Ecto.Migration

  def change do
    create table(:registered_apps, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :alias, :text, null: false
      add :heroku_name, :text, null: false
      add :github_repo, :text, null: false
    end

    create unique_index(:registered_apps, [:alias])
    create unique_index(:registered_apps, [:heroku_name])
    create unique_index(:registered_apps, [:github_repo])
  end
end
