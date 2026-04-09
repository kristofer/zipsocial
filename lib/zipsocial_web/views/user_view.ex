defmodule ZipsocialWeb.UserView do
  use ZipsocialWeb, :view

  def lang_label("java"), do: "☕ Java"
  def lang_label("python"), do: "🐍 Python"
  def lang_label(other), do: other
end
