defmodule ZipsocialWeb.Router do
  @moduledoc """
  Maps URLs to controller actions. This is your @RequestMapping table or
  Django's urls.py.

  `pipeline :browser` is a set of plugs that run before any route in the
  matching scope — like a Spring filter or a Django middleware group.

  `pipeline :admin` extends :browser with an authentication check so that
  only logged-in admins can reach the admin-only routes.

  `pipeline :require_auth` extends :browser with an auth check that allows
  either an admin session OR a regular user session.

  IMPORTANT: Phoenix matches routes top-to-bottom.  Specific paths like
  `/users/new` must be declared BEFORE wildcard paths like `/users/:id`.
  The admin-protected scope therefore appears first in the file so that
  `/users/new` is tested before `/users/:id`.
  """
  use Phoenix.Router
  import Phoenix.Controller

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {ZipsocialWeb.LayoutView, :root}
  end

  pipeline :admin do
    plug ZipsocialWeb.Plugs.RequireAdmin
  end

  pipeline :require_auth do
    plug ZipsocialWeb.Plugs.RequireAuth
  end

  # Admin-only routes — declared FIRST so specific paths like /users/new
  # are matched before the wildcard /users/:id in the public scope below.
  scope "/", ZipsocialWeb do
    pipe_through [:browser, :admin]

    # Student management (admin-only write actions)
    get "/users/new", UserController, :new
    post "/users", UserController, :create
    get "/users/:id/edit", UserController, :edit
    put "/users/:id", UserController, :update
    delete "/users/:id", UserController, :delete

    # Admin (instructor) account management
    get "/admin", AdminController, :index
    get "/admin/new", AdminController, :new
    post "/admin", AdminController, :create
    get "/admin/:id/edit", AdminController, :edit
    put "/admin/:id", AdminController, :update
    delete "/admin/:id", AdminController, :delete
  end

  # Routes that require any login (admin or regular user)
  scope "/", ZipsocialWeb do
    pipe_through [:browser, :require_auth]

    get "/posts/new", PostController, :new
    post "/posts", PostController, :create
    post "/posts/:id/comments", CommentController, :create
  end

  scope "/", ZipsocialWeb do
    pipe_through :browser

    # Home = the global feed.
    get "/", PostController, :index
    get "/java", PostController, :index_java
    get "/python", PostController, :index_python

    # Posts (read-only)
    get "/posts/:id", PostController, :show

    # Public user profile pages (read-only)
    get "/users", UserController, :index
    get "/users/:id", UserController, :show

    # Session (login / logout) — handles both admin and regular users
    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete

    # Password reset via email OTP
    get "/password-reset", PasswordResetController, :new
    post "/password-reset", PasswordResetController, :create
    get "/password-reset/:token", PasswordResetController, :edit
    post "/password-reset/:token", PasswordResetController, :update
  end
end

