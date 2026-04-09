defmodule Zipsocial.Repo do
  @moduledoc """
  The Repo is Ecto's equivalent of a JPA EntityManager or a SQLAlchemy
  session. It's how we actually talk to the database.

  All CRUD functions — `Repo.all`, `Repo.get`, `Repo.insert`, `Repo.update`,
  `Repo.delete` — hang off of this module.
  """
  use Ecto.Repo,
    otp_app: :zipsocial,
    adapter: Ecto.Adapters.SQLite3
end
