# Run with: mix run priv/repo/seeds.exs
#
# Populates the DB with a handful of students, posts, and comments so the
# feed isn't empty on first boot.

alias Zipsocial.Repo
alias Zipsocial.Social

{:ok, alex} = Social.create_user(%{
  "name" => "Alex Chen",
  "cohort" => "2026-Q2",
  "language" => "java",
  "bio" => "Backend-curious. Currently fighting with Spring Boot."
})

{:ok, priya} = Social.create_user(%{
  "name" => "Priya Shah",
  "cohort" => "2026-Q2",
  "language" => "python",
  "bio" => "Data engineering track. Loves pandas, tolerates numpy."
})

{:ok, marcus} = Social.create_user(%{
  "name" => "Marcus Johnson",
  "cohort" => "2026-Q1",
  "language" => "java",
  "bio" => "Got here from the Navy. Learning fast."
})

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
