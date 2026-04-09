defmodule Zipsocial.Social do
  @moduledoc """
  The "context" module. In Phoenix this is the conventional place to put
  business logic — it's the service layer.

  Controllers are not supposed to call Repo directly. They call functions
  here, and these functions call Repo. That keeps controllers thin and
  makes the DB code easy to test and reuse.

  If you're coming from Spring: this is your @Service class. From Django:
  it's roughly where you'd put model methods + querysets.
  """
  import Ecto.Query, warn: false
  alias Zipsocial.Repo
  alias Zipsocial.{User, Post, Comment}

  # ------------------------------- Users -------------------------------

  def list_users do
    Repo.all(from u in User, order_by: [asc: u.name])
  end

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  # ------------------------------- Posts -------------------------------

  @doc """
  The global feed. Newest first. We preload the author and comment count so
  the template doesn't trigger N+1 queries.

  The `|>` operator is just function composition read left-to-right. This:

      Post |> order_by(...) |> preload(...) |> Repo.all()

  is the same as:

      Repo.all(preload(order_by(Post, ...), ...))

  but way easier to read.
  """
  def list_feed do
    Post
    |> order_by(desc: :inserted_at)
    |> preload([:user, :comments])
    |> Repo.all()
  end

  def list_feed_by_language(lang) when lang in ["java", "python"] do
    Post
    |> where([p], p.language == ^lang)
    |> order_by(desc: :inserted_at)
    |> preload([:user, :comments])
    |> Repo.all()
  end

  def get_post!(id) do
    Post
    |> preload([:user, comments: :user])
    |> Repo.get!(id)
  end

  def create_post(attrs) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  # ------------------------------ Comments -----------------------------

  def create_comment(attrs) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
