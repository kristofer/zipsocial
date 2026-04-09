defmodule ZipsocialWeb.PostView do
  @moduledoc """
  View module for post templates. Any helper functions used by the post
  templates can live here — keep them small and presentation-focused.
  """
  use ZipsocialWeb, :view

  @doc "Pretty label for the language badge."
  def lang_label("java"), do: "☕ Java"
  def lang_label("python"), do: "🐍 Python"
  def lang_label(other), do: other

  @doc "Format a timestamp as a short relative-ish string."
  def short_time(%NaiveDateTime{} = dt) do
    Calendar.strftime(dt, "%b %d, %Y %H:%M")
  end
end
