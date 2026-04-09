defmodule ZipsocialWeb.LayoutView do
  @moduledoc """
  The view module for the shared layout templates. It picks up the files
  under lib/zipsocial_web/templates/layout/ automatically.
  """
  use ZipsocialWeb, :view

  @doc """
  Returns true when there is an active admin session on the connection.
  Used in templates to show/hide admin navigation links.
  """
  def admin_logged_in?(conn) do
    !!Plug.Conn.get_session(conn, :admin_id)
  end

  @doc """
  Returns true when a regular user (student) is logged in.
  """
  def user_logged_in?(conn) do
    !!Plug.Conn.get_session(conn, :user_id)
  end

  @doc """
  Returns true when any session (admin or regular user) is active.
  """
  def any_logged_in?(conn) do
    admin_logged_in?(conn) || user_logged_in?(conn)
  end

  @doc """
  Returns the current admin's name from the session (set at login time).
  Falls back to a DB lookup only if the session value is missing.
  """
  def current_admin_name(conn) do
    case Plug.Conn.get_session(conn, :admin_name) do
      nil ->
        case Plug.Conn.get_session(conn, :admin_id) do
          nil -> nil
          id ->
            admin = Zipsocial.Accounts.get_admin!(id)
            admin.name
        end

      name ->
        name
    end
  rescue
    _ -> nil
  end

  @doc """
  Returns the current regular user's name from the session.
  """
  def current_user_name(conn) do
    case Plug.Conn.get_session(conn, :user_name) do
      nil ->
        case Plug.Conn.get_session(conn, :user_id) do
          nil -> nil
          id ->
            user = Zipsocial.Social.get_user!(id)
            user.name
        end

      name ->
        name
    end
  rescue
    _ -> nil
  end
end

