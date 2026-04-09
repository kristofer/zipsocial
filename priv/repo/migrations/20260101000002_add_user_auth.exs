defmodule Zipsocial.Repo.Migrations.AddUserAuth do
  @moduledoc """
  Adds authentication fields to the users table so students can log in.

  - email:                unique login identifier (nullable for existing rows)
  - password_hash:        bcrypt-hashed password
  - reset_token:          a one-time password reset token
  - reset_token_expires_at: UTC expiry for the reset token
  """
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :email, :string
      add :password_hash, :string
      add :reset_token, :string
      add :reset_token_expires_at, :utc_datetime
    end

    create unique_index(:users, [:email])
    create index(:users, [:reset_token])
  end
end
