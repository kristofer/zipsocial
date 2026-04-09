defmodule Zipsocial.Accounts do
  @moduledoc """
  Context for admin user management and authentication.

  Only admins (instructors) can log in. They manage student profiles and
  other admin accounts through this context.
  """
  import Ecto.Query, warn: false
  alias Zipsocial.Repo
  alias Zipsocial.Admin

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

  # ----------------------------- Auth ------------------------------------

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
end
