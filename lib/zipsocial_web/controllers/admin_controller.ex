defmodule ZipsocialWeb.AdminController do
  @moduledoc """
  CRUD for admin (instructor) accounts.  All actions require an active admin
  session — enforced by the :admin pipeline in the router.

  GET  /admin              — list all admins
  GET  /admin/new          — new admin form
  POST /admin              — create admin
  GET  /admin/:id/edit     — edit admin form
  PUT  /admin/:id          — update admin
  DELETE /admin/:id        — delete admin
  """
  use ZipsocialWeb, :controller

  alias Zipsocial.Accounts
  alias Zipsocial.Admin

  # GET /admin
  def index(conn, _params) do
    admins = Accounts.list_admins()
    render(conn, "index.html", admins: admins)
  end

  # GET /admin/new
  def new(conn, _params) do
    changeset = Accounts.change_admin(%Admin{})
    render(conn, "new.html", changeset: changeset)
  end

  # POST /admin
  def create(conn, %{"admin" => admin_params}) do
    case Accounts.create_admin(admin_params) do
      {:ok, admin} ->
        conn
        |> put_flash(:info, "Admin #{admin.name} created successfully.")
        |> redirect(to: "/admin")

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # GET /admin/:id/edit
  def edit(conn, %{"id" => id}) do
    admin = Accounts.get_admin!(id)
    changeset = Accounts.change_admin_update(admin)
    render(conn, "edit.html", admin: admin, changeset: changeset)
  end

  # PUT /admin/:id
  def update(conn, %{"id" => id, "admin" => admin_params}) do
    admin = Accounts.get_admin!(id)

    case Accounts.update_admin(admin, admin_params) do
      {:ok, updated_admin} ->
        # If the admin is editing their own account, refresh the cached name.
        conn =
          if updated_admin.id == get_session(conn, :admin_id) do
            put_session(conn, :admin_name, updated_admin.name)
          else
            conn
          end

        conn
        |> put_flash(:info, "Admin updated successfully.")
        |> redirect(to: "/admin")

      {:error, changeset} ->
        render(conn, "edit.html", admin: admin, changeset: changeset)
    end
  end

  # DELETE /admin/:id
  def delete(conn, %{"id" => id}) do
    admin = Accounts.get_admin!(id)
    current_admin_id = get_session(conn, :admin_id)

    if admin.id == current_admin_id do
      conn
      |> put_flash(:error, "You cannot delete your own account.")
      |> redirect(to: "/admin")
    else
      {:ok, _} = Accounts.delete_admin(admin)

      conn
      |> put_flash(:info, "Admin #{admin.name} deleted.")
      |> redirect(to: "/admin")
    end
  end
end
