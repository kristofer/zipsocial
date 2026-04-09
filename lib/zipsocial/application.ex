defmodule Zipsocial.Application do
  @moduledoc """
  This is the OTP application entry point. Think of it as `main()`.

  It starts a "supervision tree" — a tree of processes that the Erlang VM
  will keep alive. If one crashes, its supervisor restarts it. This is the
  famous "let it crash" philosophy.

  For our purposes, we're just starting three things:
    1. The database repo (connection pool)
    2. Phoenix PubSub (for internal message passing)
    3. The HTTP endpoint (the web server itself)
  """
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Zipsocial.Repo,
      {Phoenix.PubSub, name: Zipsocial.PubSub},
      ZipsocialWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Zipsocial.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Called when code is reloaded in dev — tells the endpoint to re-read config.
  @impl true
  def config_change(changed, _new, removed) do
    ZipsocialWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
