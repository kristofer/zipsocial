defmodule ZipsocialWeb.Plugs.RequireAdmin do
  @moduledoc """
  A Plug that blocks unauthenticated access to admin routes.

  If the session holds `:admin_id` the request passes through. Otherwise
  the visitor is redirected to the login page with an error flash message.

  Usage in the router:
      pipeline :admin do
        plug ZipsocialWeb.Plugs.RequireAdmin
      end
  """
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  def init(opts), do: opts

  def call(conn, _opts) do
    if get_session(conn, :admin_id) do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in as an admin to access that page.")
      |> redirect(to: "/login")
      |> halt()
    end
  end
end
