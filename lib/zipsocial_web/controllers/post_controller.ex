defmodule ZipsocialWeb.PostController do
  @moduledoc """
  Handles everything under /posts and the /, /java, /python feeds.

  Every action takes `(conn, params)` — `conn` is the request/response
  struct (like HttpServletRequest + HttpServletResponse merged), and
  `params` is a map of the query/body params.
  """
  use ZipsocialWeb, :controller

  alias Zipsocial.Social
  alias Zipsocial.Post

  # GET /
  def index(conn, _params) do
    posts = Social.list_feed()
    render(conn, "index.html", posts: posts, filter: "all")
  end

  # GET /java
  def index_java(conn, _params) do
    posts = Social.list_feed_by_language("java")
    render(conn, "index.html", posts: posts, filter: "java")
  end

  # GET /python
  def index_python(conn, _params) do
    posts = Social.list_feed_by_language("python")
    render(conn, "index.html", posts: posts, filter: "python")
  end

  # GET /posts/new
  def new(conn, _params) do
    users = Social.list_users()
    changeset = Social.change_post(%Post{})
    render(conn, "new.html", changeset: changeset, users: users)
  end

  # POST /posts
  def create(conn, %{"post" => post_params}) do
    case Social.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created!")
        |> redirect(to: "/posts/#{post.id}")

      {:error, changeset} ->
        users = Social.list_users()
        render(conn, "new.html", changeset: changeset, users: users)
    end
  end

  # GET /posts/:id
  def show(conn, %{"id" => id}) do
    post = Social.get_post!(id)
    users = Social.list_users()
    comment_changeset = Social.change_comment(%Zipsocial.Comment{})
    render(conn, "show.html",
      post: post,
      users: users,
      comment_changeset: comment_changeset
    )
  end
end
