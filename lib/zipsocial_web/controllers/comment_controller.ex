defmodule ZipsocialWeb.CommentController do
  use ZipsocialWeb, :controller

  alias Zipsocial.Social

  # POST /posts/:id/comments  (requires any login — enforced by :require_auth pipeline)
  def create(conn, %{"id" => post_id, "comment" => comment_params}) do
    # Regular (non-admin) users can only comment as themselves
    comment_params =
      case get_session(conn, :admin_id) do
        nil ->
          case get_session(conn, :user_id) do
            nil -> comment_params
            user_id -> Map.put(comment_params, "user_id", user_id)
          end

        _admin_id ->
          comment_params
      end

    attrs = Map.put(comment_params, "post_id", post_id)

    case Social.create_comment(attrs) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment posted.")
        |> redirect(to: "/posts/#{post_id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Couldn't post comment. Make sure you picked a user and wrote something.")
        |> redirect(to: "/posts/#{post_id}")
    end
  end
end
