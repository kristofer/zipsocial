import Config

# runtime.exs is evaluated at runtime (when the release boots), not at compile
# time.  All environment-variable reads belong here so that a single compiled
# release can be configured by changing env vars without rebuilding the image.

if config_env() == :prod do
  # ---------------------------------------------------------------------------
  # Database — SQLite file stored on a persistent Docker volume.
  # Set DATABASE_PATH to the full path of the .db file, e.g.
  #   /app/data/zipsocial.db
  # ---------------------------------------------------------------------------
  database_path =
    System.get_env("DATABASE_PATH") ||
      raise """
      environment variable DATABASE_PATH is missing.
      Example: DATABASE_PATH=/app/data/zipsocial.db
      """

  config :zipsocial, Zipsocial.Repo,
    database: database_path,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  # ---------------------------------------------------------------------------
  # Web endpoint
  # ---------------------------------------------------------------------------
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      Generate one with: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "localhost"
  port = String.to_integer(System.get_env("PORT") || "4000")

  # URL scheme/port are used for link generation.  When running behind a
  # TLS-terminating reverse proxy set PHX_SCHEME=https and PHX_PUBLIC_PORT=443.
  # Without a proxy the defaults produce correct http://host:port links.
  url_scheme = System.get_env("PHX_SCHEME") || "http"
  url_port = String.to_integer(System.get_env("PHX_PUBLIC_PORT") || Integer.to_string(port))

  config :zipsocial, ZipsocialWeb.Endpoint,
    url: [host: host, port: url_port, scheme: url_scheme],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end
