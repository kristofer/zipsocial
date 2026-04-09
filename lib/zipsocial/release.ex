defmodule Zipsocial.Release do
  @moduledoc """
  Helper module for running Ecto migrations inside a Mix release.

  In a release there is no Mix, so we cannot run `mix ecto.migrate`.
  Instead, the Docker entrypoint calls:

      /app/bin/zipsocial eval "Zipsocial.Release.migrate()"
      /app/bin/zipsocial eval "Zipsocial.Release.seed_admin()"

  before starting the server.
  """

  @app :zipsocial

  @doc """
  Seeds the first admin account if no admins exist yet.

  Generates a random password, creates an admin with the address
  `admin@zipsocial.dev`, and prints the credentials to stdout so the
  operator can perform the initial login and then change the password.

  Safe to call on every boot — it is a no-op when an admin already exists.
  """
  def seed_admin do
    load_app()

    for repo <- repos() do
      Ecto.Migrator.with_repo(repo, fn _repo ->
        alias Zipsocial.Accounts

        case Accounts.list_admins() do
          [] ->
            password = random_password()

            {:ok, _admin} =
              Accounts.create_admin(%{
                "name" => "Head Instructor",
                "email" => "admin@zipsocial.dev",
                "password" => password,
                "password_confirmation" => password
              })

            IO.puts("""
            ============================================================
            Initial admin account created.
              Email   : admin@zipsocial.dev
              Password: #{password}
            Log in and change this password immediately!
            ============================================================
            """)

          _admins ->
            IO.puts("Admin account already exists — skipping seed.")
        end
      end)
    end
  end

  @doc "Run all pending Ecto migrations."
  def migrate do
    load_app()

    for repo <- repos() do
      case Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true)) do
        {:ok, _migrations, _apps} ->
          :ok

        {:error, reason} ->
          raise "Migration failed for #{inspect(repo)}: #{inspect(reason)}"
      end
    end
  end

  @doc "Roll back to a specific migration version."
  def rollback(repo, version) do
    load_app()

    case Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version)) do
      {:ok, _migrations, _apps} ->
        :ok

      {:error, reason} ->
        raise "Rollback failed for #{inspect(repo)} to version #{version}: #{inspect(reason)}"
    end
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

  # Generates a cryptographically random, URL-safe password (16 characters).
  defp random_password do
    :crypto.strong_rand_bytes(12) |> Base.url_encode64(padding: false)
  end
end
