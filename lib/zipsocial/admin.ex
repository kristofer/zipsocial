defmodule Zipsocial.Admin do
  @moduledoc """
  An admin user — i.e. a ZipCode instructor. Admins can log in and manage
  students (create / edit / delete) as well as other admin accounts.

  Fields:
    - email:         login credential (unique)
    - name:          display name shown in the UI
    - password_hash: bcrypt-hashed password (never stored in plain text)
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "admins" do
    field :email, :string
    field :name, :string
    field :password_hash, :string

    # Virtual field — present during form submission, never persisted.
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc """
  Changeset for creating a new admin (password required).
  """
  def changeset(admin, attrs) do
    admin
    |> cast(attrs, [:email, :name, :password, :password_confirmation])
    |> validate_required([:email, :name, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> validate_length(:password, min: 8, message: "must be at least 8 characters")
    |> validate_confirmation(:password, message: "does not match password")
    |> unique_constraint(:email)
    |> hash_password()
  end

  @doc """
  Changeset for updating an admin. Password is optional — when omitted the
  existing hash is left untouched.
  """
  def update_changeset(admin, attrs) do
    admin
    |> cast(attrs, [:email, :name, :password, :password_confirmation])
    |> validate_required([:email, :name])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> validate_password_if_present()
    |> unique_constraint(:email)
    |> hash_password()
  end

  # Only run password validations when the user actually typed something.
  defp validate_password_if_present(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      "" -> changeset
      _ ->
        changeset
        |> validate_length(:password, min: 8, message: "must be at least 8 characters")
        |> validate_confirmation(:password, message: "does not match password")
    end
  end

  # If a plain-text password was provided, hash it and store it.
  defp hash_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      "" -> changeset
      password -> put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end
end
