defmodule ZipsocialWeb.CommentController do
  use ZipsocialWeb, :controller

  alias Zipsocial.Social

  # POST /posts/:id/comments
  def create(conn, %{"id" => post_id, "comment" => comment_params}) do
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
