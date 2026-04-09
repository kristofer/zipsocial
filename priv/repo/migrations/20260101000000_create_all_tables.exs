defmodule Zipsocial.Repo.Migrations.CreateAllTables do
  @moduledoc """
  A migration is just a module with up/down (or `change`) functions that
  Ecto runs in order. Similar to Flyway / Alembic. The filename's timestamp
  is how Ecto knows the order.

  Run with `mix ecto.migrate`. Roll back with `mix ecto.rollback`.
  """
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :cohort, :string, null: false
      add :language, :string, null: false
      add :bio, :text
      timestamps()
    end

    create table(:posts) do
      add :title, :string, null: false
      add :body, :text, null: false
      add :repo_url, :string
      add :language, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end

    create index(:posts, [:user_id])
    create index(:posts, [:language])

    create table(:comments) do
      add :body, :text, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :post_id, references(:posts, on_delete: :delete_all), null: false
      timestamps()
    end

    create index(:comments, [:post_id])
    create index(:comments, [:user_id])
  end
end
