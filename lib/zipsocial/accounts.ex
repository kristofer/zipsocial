defmodule Zipsocial.Accounts do
  @moduledoc """
  Context for admin and user authentication.

  Admins (instructors) can manage all data. Regular users (students) can
  log in and post or comment only as themselves.
  """
  import Ecto.Query, warn: false
  alias Zipsocial.Repo
  alias Zipsocial.{Admin, User}

  # ----------------------------- Admins ----------------------------------

  def list_admins do
    Repo.all(from a in Admin, order_by: [asc: a.name])
  end

  def get_admin!(id), do: Repo.get!(Admin, id)

  def get_admin_by_email(email) do
    Repo.get_by(Admin, email: email)
  end

  def create_admin(attrs) do
    %Admin{}
    |> Admin.changeset(attrs)
    |> Repo.insert()
  end

  def update_admin(%Admin{} = admin, attrs) do
    admin
    |> Admin.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_admin(%Admin{} = admin) do
    Repo.delete(admin)
  end

  def change_admin(%Admin{} = admin, attrs \\ %{}) do
    Admin.changeset(admin, attrs)
  end

  def change_admin_update(%Admin{} = admin, attrs \\ %{}) do
    Admin.update_changeset(admin, attrs)
  end

  # ----------------------------- Admin Auth ------------------------------

  @doc """
  Verifies email/password and returns {:ok, admin} or :error.
  """
  def authenticate_admin(email, password) when is_binary(email) and is_binary(password) do
    admin = get_admin_by_email(email)

    cond do
      is_nil(admin) ->
        # Run a dummy check to avoid timing attacks
        Bcrypt.no_user_verify()
        :error

      Bcrypt.verify_pass(password, admin.password_hash) ->
        {:ok, admin}

      true ->
        :error
    end
  end

  # ----------------------------- Users -----------------------------------

  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Sets the default password (zipcode0) for a user that has an email
  but no password yet.
  """
  def set_default_password(%User{} = user) do
    user
    |> User.password_changeset(%{"password" => "zipcode0", "password_confirmation" => "zipcode0"})
    |> Repo.update()
  end

  # ----------------------------- User Auth --------------------------------

  @doc """
  Verifies email/password for a regular user and returns {:ok, user} or :error.
  """
  def authenticate_user(email, password) when is_binary(email) and is_binary(password) do
    user = get_user_by_email(email)

    cond do
      is_nil(user) ->
        Bcrypt.no_user_verify()
        :error

      is_nil(user.password_hash) ->
        :error

      Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, user}

      true ->
        :error
    end
  end

  # ----------------------------- Password Reset --------------------------

  # Token expiry: 2 hours from generation
  @reset_token_expiry_seconds 7_200

  @doc """
  Generates a 6-character uppercase OTP reset code for a user identified by
  email. Returns {:ok, token, user} so the caller can display or email the code,
  or {:error, :not_found} when no user with that email exists.

  The token is stored in the DB and expires in 2 hours.
  """
  def generate_password_reset_token(email) when is_binary(email) do
    case get_user_by_email(email) do
      nil ->
        {:error, :not_found}

      user ->
        # 6-char uppercase alphanumeric OTP
        token =
          :crypto.strong_rand_bytes(4)
          |> Base.encode32(padding: false)
          |> String.slice(0, 6)

        expires_at =
          DateTime.utc_now()
          |> DateTime.add(@reset_token_expiry_seconds, :second)
          |> DateTime.truncate(:second)

        {:ok, _user} =
          user
          |> User.reset_token_changeset(token, expires_at)
          |> Repo.update()

        {:ok, token, user}
    end
  end

  @doc """
  Resets a user's password using the OTP token.

  Returns {:ok, user} on success, {:error, reason} on failure.
  Reasons: :invalid_token, :expired_token, :invalid_password
  """
  def reset_password(token, new_password, confirmation) when is_binary(token) do
    now = DateTime.utc_now()

    case Repo.get_by(User, reset_token: token) do
      nil ->
        {:error, :invalid_token}

      user ->
        if DateTime.compare(user.reset_token_expires_at, now) == :lt do
          {:error, :expired_token}
        else
          result =
            user
            |> User.password_changeset(%{
              "password" => new_password,
              "password_confirmation" => confirmation
            })
            |> Repo.update()

          case result do
            {:ok, updated_user} ->
              # Clear the token so it can't be reused
              updated_user
              |> User.clear_reset_token_changeset()
              |> Repo.update()

            {:error, changeset} ->
              {:error, changeset}
          end
        end
    end
  end
end

