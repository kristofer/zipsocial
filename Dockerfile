# ============================================================
# Stage 1 — Builder
# ============================================================
# We use the official Elixir Alpine image so that we have Mix, Hex, and the
# Erlang tool-chain already installed.  Alpine keeps the image small.
FROM elixir:1.15-alpine AS builder

# build-base  → gcc, make (needed to compile the exqlite NIF)
# git         → some Hex packages fetch from git
# sqlite-dev  → SQLite headers + static lib for the exqlite NIF
RUN apk add --no-cache build-base git sqlite-dev

WORKDIR /app

# Install Hex + Rebar (mix package manager helpers).
RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

# ---- Dependency layer (cached unless mix.exs / mix.lock change) ----
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# Copy config before compiling deps so that compile-time config is available.
COPY config config

RUN mix deps.compile

# ---- Application layer ----
COPY priv priv
COPY lib lib

RUN mix compile

# Build a self-contained Mix release.
RUN mix release

# ============================================================
# Stage 2 — Runtime
# ============================================================
# A minimal Alpine image — no Elixir/Mix tool-chain, just what the BEAM
# runtime and exqlite need at run time.
FROM alpine:3.18 AS app

# libstdc++ / openssl / ncurses-libs → required by the Erlang runtime
# sqlite-libs                        → SQLite shared library used by exqlite
RUN apk add --no-cache libstdc++ openssl ncurses-libs sqlite-libs

WORKDIR /app

# Run as an unprivileged user for better security.
RUN addgroup -g 1001 -S elixir && \
    adduser  -u 1001 -S elixir -G elixir

# Copy the compiled release from the builder stage.
COPY --from=builder --chown=elixir:elixir /app/_build/prod/rel/zipsocial ./

# The SQLite database will be stored in /app/data, which should be mounted
# as a Docker volume to survive container restarts.
RUN mkdir -p /app/data && chown elixir:elixir /app/data

# Copy the entrypoint script (runs migrations, then starts the server).
COPY --chown=elixir:elixir entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

USER elixir

EXPOSE 4000

# Default environment — override these at runtime (see docker-compose.yml).
ENV PHX_HOST=localhost \
    PORT=4000

ENTRYPOINT ["/app/entrypoint.sh"]
