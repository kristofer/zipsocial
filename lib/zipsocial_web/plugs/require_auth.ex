defmodule ZipsocialWeb.Plugs.RequireAuth do
  @moduledoc """
  A Plug that blocks unauthenticated access to routes that require a login.

  Either an admin session (:admin_id) or a regular user session (:user_id)
  is sufficient to pass through. Unauthenticated visitors are redirected to
  the login page.

  Usage in the router:
      pipeline :require_auth do
        plug ZipsocialWeb.Plugs.RequireAuth
      end
  """
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  def init(opts), do: opts

  def call(conn, _opts) do
    if get_session(conn, :admin_id) || get_session(conn, :user_id) do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to do that.")
      |> redirect(to: "/login")
      |> halt()
    end
  end
end
