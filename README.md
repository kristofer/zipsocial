# ZipSocial

A very simple social network for ZipCode Wilmington students to share their
Java and Python projects and talk about their repos.

Built with **Phoenix + SQLite**. Kept intentionally small so folks new to
Elixir can read the whole thing in an afternoon.

## What it does

- Students create a profile (name, cohort, language: Java or Python)
- They post updates about their repos (title, GitHub URL, language, body)
- Anyone can view a global feed of posts
- Anyone can comment on a post

That's it. No auth, no JS framework, no LiveView yet — just server-rendered
HTML. Once the team is comfortable we can layer more on.

## Mental model for Java/Python folks

| You know...                    | In Phoenix it's...                                 |
|--------------------------------|----------------------------------------------------|
| Spring `@Controller` / Flask route | A function in a module under `lib/zipsocial_web/controllers` |
| JPA `@Entity` / SQLAlchemy model  | An Ecto schema (`lib/zipsocial/*.ex`)             |
| `application.properties`          | `config/config.exs` and `config/dev.exs`           |
| Hibernate/Alembic migration       | A file in `priv/repo/migrations`                   |
| Jinja / Thymeleaf template        | A `.heex` file under `lib/zipsocial_web/templates` |
| `main()` / Spring Boot run        | `mix phx.server`                                   |

Key vocabulary:
- **Mix** — build tool (like Maven, or pip+setuptools).
- **Ecto** — the DB library. `Repo` = your `EntityManager` / SQLAlchemy session.
- **Plug** — middleware. A "conn" (connection) flows through plugs like a
  Java servlet request/response flows through filters.
- **Module** — a namespace. Starts with `defmodule Foo do ... end`.
- **`|>`** — the pipe operator. `a |> b() |> c()` is `c(b(a))`. Read left to right.

## Running it (once Elixir is installed)

```bash
# 1. Install Elixir + Erlang. On macOS:
#    brew install elixir
# On Ubuntu:
#    sudo apt install elixir erlang-dev erlang-xmerl

# 2. Install Phoenix and deps
mix local.hex --force
mix archive.install hex phx_new --force
mix deps.get

# 3. Create and migrate the SQLite DB
mix ecto.create
mix ecto.migrate

# 4. Run the server
mix phx.server
```

Then open http://localhost:4000.

The SQLite file lives at `zipsocial_dev.db` in the project root.

## File tour (read in this order)

1. `mix.exs` — dependencies (like `pom.xml` / `requirements.txt`)
2. `config/config.exs` + `config/dev.exs` — app + DB config
3. `priv/repo/migrations/*.exs` — create the tables
4. `lib/zipsocial/user.ex` — User schema (like a JPA entity)
5. `lib/zipsocial/post.ex` — Post schema
6. `lib/zipsocial/comment.ex` — Comment schema
7. `lib/zipsocial/social.ex` — the "service layer": all DB calls live here
8. `lib/zipsocial_web/router.ex` — URL → controller mapping
9. `lib/zipsocial_web/controllers/*.ex` — request handlers
10. `lib/zipsocial_web/templates/**/*.heex` — the HTML

Start with `social.ex` — it's the heart of the app.
