defmodule MessageIndexer.Application do

  @moduledoc false

  use Application
  require Logger
  alias MessageIndexer.Router

  def start(_type, _args) do
    Logger.info("Starting message indexer")

    children = [
      Router
    ]

    opts = [strategy: :one_for_one, name: MessageIndexer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
