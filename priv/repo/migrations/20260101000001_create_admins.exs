defmodule Zipsocial.Repo.Migrations.CreateAdmins do
  @moduledoc """
  Adds the `admins` table for instructor accounts.
  Run with `mix ecto.migrate`. Roll back with `mix ecto.rollback`.
  """
  use Ecto.Migration

  def change do
    create table(:admins) do
      add :email, :string, null: false
      add :name, :string, null: false
      add :password_hash, :string, null: false
      timestamps()
    end

    create unique_index(:admins, [:email])
  end
end
