# Run with: mix run priv/repo/seeds.exs
#
# Populates the DB with a handful of students, posts, and comments so the
# feed isn't empty on first boot, plus a default admin (instructor) account.

alias Zipsocial.Repo
alias Zipsocial.Social
alias Zipsocial.Accounts

# ----------------------------- Admin seed --------------------------------
# Creates an instructor account with a random password on first run.
# Also ensures a corresponding User record exists with the same email
# so the instructor can also log in as a regular student.
# The generated password is printed to the log — change it after first login!
case Accounts.get_admin_by_email("admin@zipsocial.dev") do
  nil ->
    password = :crypto.strong_rand_bytes(12) |> Base.url_encode64(padding: false)

    {:ok, admin} = Accounts.create_admin(%{
      "name"                  => "Head Instructor",
      "email"                 => "admin@zipsocial.dev",
      "password"              => password,
      "password_confirmation" => password
    })

    # Create corresponding User so the instructor can also log in as a student
    case Social.get_user_by_email(admin.email) do
      nil ->
        case Social.create_user(%{
          "name"     => admin.name,
          "email"    => admin.email,
          "cohort"   => "admin",
          "language" => "java"
        }) do
          {:ok, user} -> Accounts.set_default_password(user)
          _ -> :ok
        end
      _ -> :ok
    end

    IO.puts("""
    ============================================================
    Initial admin account created.
      Email         : admin@zipsocial.dev
      Admin password: #{password}
      User password : zipcode0
    Log in as admin at /login with the admin password.
    Log in as a student at /login with password: zipcode0
    Change the admin password immediately after first login!
    ============================================================
    """)

  _existing ->
    IO.puts("Default admin already exists, skipping.")
end

# ----------------------------- Student seeds -----------------------------
# Create sample students with emails so they can log in.
# Default password for all is: zipcode0

{:ok, alex} = Social.create_user(%{
  "name" => "Alex Chen",
  "email" => "alex@zipsocial.dev",
  "cohort" => "2026-Q2",
  "language" => "java",
  "bio" => "Backend-curious. Currently fighting with Spring Boot."
})
Accounts.set_default_password(alex)

{:ok, priya} = Social.create_user(%{
  "name" => "Priya Shah",
  "email" => "priya@zipsocial.dev",
  "cohort" => "2026-Q2",
  "language" => "python",
  "bio" => "Data engineering track. Loves pandas, tolerates numpy."
})
Accounts.set_default_password(priya)

{:ok, marcus} = Social.create_user(%{
  "name" => "Marcus Johnson",
  "email" => "marcus@zipsocial.dev",
  "cohort" => "2026-Q1",
  "language" => "java",
  "bio" => "Got here from the Navy. Learning fast."
})
Accounts.set_default_password(marcus)

{:ok, post1} = Social.create_post(%{
  "user_id" => alex.id,
  "title" => "First REST API with Spring Boot",
  "language" => "java",
  "repo_url" => "https://github.com/alexchen/spring-starter",
  "body" => "Finally got my CRUD endpoints working. The hardest part was figuring out why my JPA queries were returning null — turns out I forgot @Transactional. Any tips on structuring controllers vs services?"
})

{:ok, _post2} = Social.create_post(%{
  "user_id" => priya.id,
  "title" => "ETL pipeline for city bus data",
  "language" => "python",
  "repo_url" => "https://github.com/priyashah/bus-etl",
  "body" => "Pulling from Wilmington's open data portal, cleaning with pandas, loading to SQLite. Next step: throw it into a dashboard. Open to feedback on the schema."
})

{:ok, _post3} = Social.create_post(%{
  "user_id" => marcus.id,
  "title" => "Trying to understand generics",
  "language" => "java",
  "body" => "Can someone explain why `List<Object>` is not the same as `List<String>`? I get that it's about type safety but the wildcards are melting my brain."
})

Social.create_comment(%{
  "user_id" => priya.id,
  "post_id" => post1.id,
  "body" => "I'd keep controllers thin — just parse input and delegate to a service. Makes testing way easier."
})

Social.create_comment(%{
  "user_id" => marcus.id,
  "post_id" => post1.id,
  "body" => "Nice! Mind if I crib your project structure for mine?"
})

IO.puts("Seeded #{length(Social.list_users())} users and #{length(Social.list_feed())} posts.")
IO.puts("Student login emails: alex@zipsocial.dev, priya@zipsocial.dev, marcus@zipsocial.dev")
IO.puts("Default student password: zipcode0")

