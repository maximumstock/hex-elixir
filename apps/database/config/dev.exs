use Mix.Config

config :database, Database.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "hex",
  username: "hex",
  password: "hex",
  hostname: "localhost"

