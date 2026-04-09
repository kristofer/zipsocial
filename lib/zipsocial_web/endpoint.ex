defmodule ZipsocialWeb.Endpoint do
  @moduledoc """
  The Endpoint is the entry point for every HTTP request. It's a pipeline
  of "plugs" (middleware) that run in order: parse the body, put secure
  headers, dispatch to the router, etc.

  If you're coming from Spring, this is kind of like your DispatcherServlet
  + filter chain config. From Rack/WSGI, it's the app callable.
  """
  use Phoenix.Endpoint, otp_app: :zipsocial

  # Session config — cookie-based sessions, signed.
  @session_options [
    store: :cookie,
    key: "_zipsocial_key",
    signing_salt: "zipzipzip",
    same_site: "Lax"
  ]

  # Hot code reload socket (dev only).
  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]]

  # Serve static files out of priv/static.
  plug Plug.Static,
    at: "/",
    from: :zipsocial,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)

  if code_reloading? do
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug ZipsocialWeb.Router
end
