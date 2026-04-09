import Config

# ---------------------------------------------------------------------------
# Main app config. Think of this as application.properties.
# ---------------------------------------------------------------------------

config :zipsocial,
  ecto_repos: [Zipsocial.Repo],
  generators: [binary_id: false]

# Tells Phoenix which Repo module to use and some endpoint basics.
config :zipsocial, ZipsocialWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: ZipsocialWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: Zipsocial.PubSub,
  live_view: [signing_salt: "change_me_in_prod"]

config :phoenix, :json_library, Jason

# Environment-specific stuff lives in config/dev.exs etc.
import_config "#{config_env()}.exs"
