defmodule ZipsocialWeb.UserController do
  use ZipsocialWeb, :controller

  alias Zipsocial.Social
  alias Zipsocial.User

  # GET /users
  def index(conn, _params) do
    users = Social.list_users()
    render(conn, "index.html", users: users)
  end

  # GET /users/new
  def new(conn, _params) do
    changeset = Social.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  # POST /users
  def create(conn, %{"user" => user_params}) do
    case Social.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome, #{user.name}!")
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
end
