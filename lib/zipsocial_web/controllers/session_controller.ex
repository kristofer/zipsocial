defmodule ZipsocialWeb.SessionController do
  @moduledoc """
  Handles admin login and logout.

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
  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Accounts.authenticate_admin(email, password) do
      {:ok, admin} ->
        conn
        |> put_session(:admin_id, admin.id)
        |> put_session(:admin_name, admin.name)
        |> put_flash(:info, "Welcome back, #{admin.name}!")
        |> redirect(to: "/admin")

      :error ->
        conn
        |> put_flash(:error, "Invalid email or password.")
        |> render("new.html")
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
