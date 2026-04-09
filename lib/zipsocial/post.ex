defmodule Zipsocial.Post do
  @moduledoc """
  A post about a repo or project. Each post belongs to a user, and may
  have many comments.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :body, :string
    field :repo_url, :string
    field :language, :string  # "java" or "python"

    # @ManyToOne equivalent. `belongs_to` creates a `user_id` foreign key
    # column and a virtual `user` association you can preload.
    belongs_to :user, Zipsocial.User
    has_many :comments, Zipsocial.Comment

    timestamps()
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :repo_url, :language, :user_id])
    |> validate_required([:title, :body, :language, :user_id])
    |> validate_inclusion(:language, ["java", "python"])
    |> validate_length(:title, min: 3, max: 140)
    |> validate_format(:repo_url, ~r/^https?:\/\//,
        message: "should start with http:// or https://")
  end
end
