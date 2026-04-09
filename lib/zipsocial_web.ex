defmodule ZipsocialWeb do
  @moduledoc """
  Boilerplate macro module. When a file says `use ZipsocialWeb, :controller`
  it expands into the controller setup below. Don't worry too much about
  this file — treat it as framework glue.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: ZipsocialWeb
      import Plug.Conn
      alias ZipsocialWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/zipsocial_web/templates",
        namespace: ZipsocialWeb

      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]
      import Phoenix.HTML
      import Phoenix.Component
      alias ZipsocialWeb.Router.Helpers, as: Routes
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
