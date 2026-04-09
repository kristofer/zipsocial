defmodule ZipsocialWeb.ErrorHTML do
  @moduledoc """
  Minimal error rendering. Phoenix calls this when a request blows up or
  hits a 404. Returns a tiny plain-text-ish response.
  """
  use ZipsocialWeb, :view

  def render("404.html", _assigns), do: "Not found"
  def render("500.html", _assigns), do: "Server error"
  def template_not_found(template, _assigns), do: Phoenix.Controller.status_message_from_template(template)
end
