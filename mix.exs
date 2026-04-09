defmodule Zipsocial.MixProject do
  # This file is like pom.xml or requirements.txt + setup.py.
  # It declares the project name, version, and dependencies.
  use Mix.Project

  def project do
    [
      app: :zipsocial,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # This tells Elixir which OTP application to boot and what extra
  # built-in apps to start. `Zipsocial.Application` is our entry point
  # (see lib/zipsocial/application.ex).
  def application do
    [
      mod: {Zipsocial.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    [
      # Phoenix itself — the web framework. Think Spring Boot / Django.
      {:phoenix, "~> 1.7.10"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_ecto, "~> 4.5"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.1"},

      # Ecto = the ORM. ecto_sqlite3 is the SQLite adapter.
      {:ecto_sql, "~> 3.10"},
      {:ecto_sqlite3, "~> 0.12"},

      # Password hashing for admin authentication
      {:bcrypt_elixir, "~> 3.0"},

      # Misc
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"}
    ]
  end
end
