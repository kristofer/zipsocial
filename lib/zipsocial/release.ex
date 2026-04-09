defmodule Zipsocial.Release do
  @moduledoc """
  Helper module for running Ecto migrations inside a Mix release.

  In a release there is no Mix, so we cannot run `mix ecto.migrate`.
  Instead, the Docker entrypoint calls:

      /app/bin/zipsocial eval "Zipsocial.Release.migrate()"

  before starting the server.
  """

  @app :zipsocial

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
end
