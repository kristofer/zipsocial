#!/bin/sh
# entrypoint.sh — Docker container entrypoint for ZipSocial.
#
# Runs pending database migrations, seeds the first admin account (if none
# exists), then hands off to the Phoenix release.
# Using `exec` replaces this shell process so that the Erlang VM receives
# signals (SIGTERM, etc.) directly.

set -e

echo "==> Running database migrations…"
/app/bin/zipsocial eval "Zipsocial.Release.migrate()"

echo "==> Seeding initial admin account (no-op if one already exists)…"
/app/bin/zipsocial eval "Zipsocial.Release.seed_admin()"

echo "==> Starting ZipSocial…"
exec /app/bin/zipsocial start
