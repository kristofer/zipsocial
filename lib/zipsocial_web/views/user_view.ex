defmodule ZipsocialWeb.UserView do
  use ZipsocialWeb, :view

  import ZipsocialWeb.LayoutView, only: [admin_logged_in?: 1]

  def lang_label("java"), do: "☕ Java"
  def lang_label("python"), do: "🐍 Python"
  def lang_label(other), do: other
end
