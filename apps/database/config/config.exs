use Mix.Config

config :database, ecto_repos: [Database.Repo],
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DBNAME") || "hex",
  username: System.get_env("DBUSER") || "hex",
  password: System.get_env("DBPASS") || "hex",
  hostname: System.get_env("DBHOST") || "localhost"

import_config "#{Mix.env}.exs"
