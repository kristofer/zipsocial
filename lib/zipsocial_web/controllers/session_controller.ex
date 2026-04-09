defmodule ZipsocialWeb.SessionController do
  @moduledoc """
  Handles login and logout for both admin (instructors) and regular users
  (students).

  GET  /login  — render the login form
  POST /login  — authenticate and start a session
  DELETE /logout — end the session
  """
  use ZipsocialWeb, :controller

  alias Zipsocial.Accounts

  # GET /login
  def new(conn, _params) do
    render(conn, "new.html")
  end

  # POST /login
  # Try admin auth first; fall back to regular user auth.
  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Accounts.authenticate_admin(email, password) do
      {:ok, admin} ->
        conn
        |> put_session(:admin_id, admin.id)
        |> put_session(:admin_name, admin.name)
        |> put_flash(:info, "Welcome back, #{admin.name}!")
        |> redirect(to: "/admin")

      :error ->
        case Accounts.authenticate_user(email, password) do
          {:ok, user} ->
            conn
            |> put_session(:user_id, user.id)
            |> put_session(:user_name, user.name)
            |> put_flash(:info, "Welcome back, #{user.name}!")
            |> redirect(to: "/")

          :error ->
            conn
            |> put_flash(:error, "Invalid email or password.")
            |> render("new.html")
        end
    end
  end

  # DELETE /logout
  def delete(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "You have been logged out.")
    |> redirect(to: "/")
  end
end

