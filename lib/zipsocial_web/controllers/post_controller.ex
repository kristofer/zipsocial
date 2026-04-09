defmodule ZipsocialWeb.PostController do
  @moduledoc """
  Handles everything under /posts and the /, /java, /python feeds.

  Every action takes `(conn, params)` — `conn` is the request/response
  struct (like HttpServletRequest + HttpServletResponse merged), and
  `params` is a map of the query/body params.

  Authorization rules:
  - Viewing the feed and individual posts is public.
  - Creating a post requires a login (admin OR user).
  - Admins can post as any user; regular users can only post as themselves.
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

  # GET /posts/new  (requires any login — enforced by :require_auth pipeline)
  def new(conn, _params) do
    users = users_for_session(conn)
    changeset = Social.change_post(%Post{})
    render(conn, "new.html",
      changeset: changeset,
      users: users,
      current_user_id: get_session(conn, :user_id)
    )
  end

  # POST /posts  (requires any login — enforced by :require_auth pipeline)
  def create(conn, %{"post" => post_params}) do
    # Regular (non-admin) users can only post as themselves
    post_params = enforce_user_id(conn, post_params)

    case Social.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created!")
        |> redirect(to: "/posts/#{post.id}")

      {:error, changeset} ->
        users = users_for_session(conn)
        render(conn, "new.html",
          changeset: changeset,
          users: users,
          current_user_id: get_session(conn, :user_id)
        )
    end
  end

  # GET /posts/:id
  def show(conn, %{"id" => id}) do
    post = Social.get_post!(id)
    users = users_for_session(conn)
    comment_changeset = Social.change_comment(%Zipsocial.Comment{})
    render(conn, "show.html",
      post: post,
      users: users,
      comment_changeset: comment_changeset,
      current_user_id: get_session(conn, :user_id)
    )
  end

  # --------------- helpers ------------------------------------------------

  # Returns the list of users that the current session may post as.
  # Admins get all users; regular users get only themselves.
  # The nil branch for user_id is unreachable in practice (the :require_auth
  # pipeline ensures at least one session is present) but is kept for safety.
  defp users_for_session(conn) do
    case get_session(conn, :admin_id) do
      nil ->
        case get_session(conn, :user_id) do
          nil -> []
          user_id -> [Social.get_user!(user_id)]
        end

      _admin_id ->
        Social.list_users()
    end
  end

  # For a regular user session, override the user_id in params so they
  # cannot post as someone else. Admins are not restricted.
  defp enforce_user_id(conn, post_params) do
    case get_session(conn, :admin_id) do
      nil ->
        case get_session(conn, :user_id) do
          nil -> post_params
          user_id -> Map.put(post_params, "user_id", user_id)
        end

      _admin_id ->
        post_params
    end
  end
end
