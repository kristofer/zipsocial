defmodule Zipsocial.User do
  @moduledoc """
  A ZipCode student. This is an Ecto schema — the equivalent of a JPA
  @Entity class or a SQLAlchemy model.

  Fields:
    - name:     display name
    - cohort:   which ZipCode cohort (e.g. "2025-Q2")
    - language: their primary language, "java" or "python"
    - bio:      short self-description
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :cohort, :string
    field :language, :string
    field :bio, :string

    # A user has many posts and many comments.
    # This is the Ecto version of @OneToMany.
    has_many :posts, Zipsocial.Post
    has_many :comments, Zipsocial.Comment

    # `timestamps()` adds `inserted_at` and `updated_at` columns automatically.
    timestamps()
  end

  @doc """
  A "changeset" is Ecto's way of validating and casting incoming data before
  it touches the DB. You can think of it as Bean Validation (@NotNull, @Size)
  combined with a DTO mapper.

  The typical pattern is:
      %User{} |> User.changeset(params) |> Repo.insert()
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :cohort, :language, :bio])
    |> validate_required([:name, :cohort, :language])
    |> validate_inclusion(:language, ["java", "python"])
    |> validate_length(:name, min: 2, max: 50)
  end
end
