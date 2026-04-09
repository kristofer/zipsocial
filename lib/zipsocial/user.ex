defmodule Zipsocial.User do
  @moduledoc """
  A ZipCode student. This is an Ecto schema — the equivalent of a JPA
  @Entity class or a SQLAlchemy model.

  Fields:
    - name:                   display name
    - cohort:                 which ZipCode cohort (e.g. "2025-Q2")
    - language:               their primary language, "java" or "python"
    - bio:                    short self-description
    - email:                  login credential (unique, optional for legacy rows)
    - password_hash:          bcrypt-hashed password (never stored in plain text)
    - reset_token:            one-time password-reset token
    - reset_token_expires_at: UTC expiry for the reset token
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :cohort, :string
    field :language, :string
    field :bio, :string

    # Auth fields
    field :email, :string
    field :password_hash, :string
    field :reset_token, :string
    field :reset_token_expires_at, :utc_datetime

    # Virtual fields — present during form submission, never persisted.
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    # A user has many posts and many comments.
    # This is the Ecto version of @OneToMany.
    has_many :posts, Zipsocial.Post
    has_many :comments, Zipsocial.Comment

    # `timestamps()` adds `inserted_at` and `updated_at` columns automatically.
    timestamps()
  end

  @doc """
  A "changeset" is Ecto's way of validating and casting incoming data before
  it touches the DB. You can think of it as Bean Validation (@NotNull, @Size)
  combined with a DTO mapper.

  The typical pattern is:
      %User{} |> User.changeset(params) |> Repo.insert()
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :cohort, :language, :bio, :email])
    |> validate_required([:name, :cohort, :language])
    |> validate_inclusion(:language, ["java", "python"])
    |> validate_length(:name, min: 2, max: 50)
    |> validate_email_if_present()
    |> unique_constraint(:email)
  end

  @doc """
  Changeset used when an admin edits an existing student profile.
  All fields are updatable; none are required to change each time.
  """
  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :cohort, :language, :bio, :email])
    |> validate_required([:name, :cohort, :language])
    |> validate_inclusion(:language, ["java", "python"])
    |> validate_length(:name, min: 2, max: 50)
    |> validate_email_if_present()
    |> unique_constraint(:email)
  end

  @doc """
  Changeset for setting or updating a user's password.
  Used when an admin creates a user account or a user resets their password.
  """
  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password])
    |> validate_length(:password, min: 6, message: "must be at least 6 characters")
    |> validate_confirmation(:password, message: "does not match password")
    |> hash_password()
  end

  @doc """
  Changeset for storing a password-reset OTP token.
  """
  def reset_token_changeset(user, token, expires_at) do
    change(user, reset_token: token, reset_token_expires_at: expires_at)
  end

  @doc """
  Changeset to clear the reset token after a successful password reset.
  """
  def clear_reset_token_changeset(user) do
    change(user, reset_token: nil, reset_token_expires_at: nil)
  end

  # Only validate email format when a non-empty email was provided.
  defp validate_email_if_present(changeset) do
    case get_field(changeset, :email) do
      nil -> changeset
      "" -> changeset
      _ ->
        changeset
        |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/,
            message: "must be a valid email address")
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
