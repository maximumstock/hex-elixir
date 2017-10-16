use Mix.Config

config :database, Database.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DBNAME"),
  username: System.get_env("DBUSER"),
  password: System.get_env("DBPASS"),
  hostname: System.get_env("DBHOST")
