import Config

# For production releases, always start the HTTP server.
config :zipsocial, ZipsocialWeb.Endpoint, server: true

# Log at info level in production.
config :logger, level: :info
