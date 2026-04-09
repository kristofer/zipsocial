defmodule Zipsocial.Comment do
  @moduledoc """
  A comment on a post. Belongs to both a user (the author) and a post.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :body, :string

    belongs_to :user, Zipsocial.User
    belongs_to :post, Zipsocial.Post

    timestamps()
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :user_id, :post_id])
    |> validate_required([:body, :user_id, :post_id])
    |> validate_length(:body, min: 1, max: 1000)
  end
end
