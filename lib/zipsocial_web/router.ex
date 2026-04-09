defmodule ZipsocialWeb.Router do
  @moduledoc """
  Maps URLs to controller actions. This is your @RequestMapping table or
  Django's urls.py.

  `pipeline :browser` is a set of plugs that run before any route in the
  matching scope — like a Spring filter or a Django middleware group.
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

  scope "/", ZipsocialWeb do
    pipe_through :browser

    # Home = the global feed.
    get "/", PostController, :index
    get "/java", PostController, :index_java
    get "/python", PostController, :index_python

    # Posts
    get "/posts/new", PostController, :new
    post "/posts", PostController, :create
    get "/posts/:id", PostController, :show
    post "/posts/:id/comments", CommentController, :create

    # Users
    get "/users", UserController, :index
    get "/users/new", UserController, :new
    post "/users", UserController, :create
    get "/users/:id", UserController, :show
  end
end
