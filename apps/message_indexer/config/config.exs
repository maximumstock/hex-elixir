use Mix.Config

config :message_indexer, port: System.get_env("PORT") || 9000

import_config "#{Mix.env}.exs"
