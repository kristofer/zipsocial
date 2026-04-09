defmodule ZipsocialWeb.UserController do
  use ZipsocialWeb, :controller

  alias Zipsocial.Social
  alias Zipsocial.User

  # GET /users
  def index(conn, _params) do
    users = Social.list_users()
    render(conn, "index.html", users: users)
  end

  # GET /users/new  (admin-protected in router)
  def new(conn, _params) do
    changeset = Social.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  # POST /users  (admin-protected in router)
  def create(conn, %{"user" => user_params}) do
    case Social.create_user(user_params) do
      {:ok, user} ->
        # If an email was provided, set the default password so the student
        # can log in immediately.
        if user.email && user.email != "" do
          Zipsocial.Accounts.set_default_password(user)
        end

        conn
        |> put_flash(:info, "Student #{user.name} created successfully!")
        |> redirect(to: "/users/#{user.id}")

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # GET /users/:id
  def show(conn, %{"id" => id}) do
    user = Social.get_user!(id) |> Zipsocial.Repo.preload(:posts)
    render(conn, "show.html", user: user)
  end

  # GET /users/:id/edit  (admin-protected in router)
  def edit(conn, %{"id" => id}) do
    user = Social.get_user!(id)
    changeset = Social.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  # PUT /users/:id  (admin-protected in router)
  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Social.get_user!(id)

    case Social.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Student profile updated.")
        |> redirect(to: "/users/#{user.id}")

      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  # DELETE /users/:id  (admin-protected in router)
  def delete(conn, %{"id" => id}) do
    user = Social.get_user!(id)
    {:ok, _} = Social.delete_user(user)

    conn
    |> put_flash(:info, "Student #{user.name} removed.")
    |> redirect(to: "/users")
  end
end

