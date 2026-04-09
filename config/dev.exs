import Config

# ---------------------------------------------------------------------------
# Development config. This is what runs when you do `mix phx.server`.
# ---------------------------------------------------------------------------

# SQLite config. The DB is just a file on disk. Super simple.
config :zipsocial, Zipsocial.Repo,
  database: Path.expand("../zipsocial_dev.db", __DIR__),
  pool_size: 5,
  show_sensitive_data_on_connection_error: true

# The HTTP endpoint — listens on port 4000 by default.
config :zipsocial, ZipsocialWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "REPLACE_ME_WITH_A_REAL_SECRET_IN_PROD_64_CHARS_MINIMUM_ABCDEFGHIJKLMNOPQ",
  watchers: []

# Phoenix hot-reloads templates and code on save — no restart needed.
config :zipsocial, ZipsocialWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"lib/zipsocial_web/(controllers|live|components|templates)/.*(ex|heex)$"
    ]
  ]

config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
