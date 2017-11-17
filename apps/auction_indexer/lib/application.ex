defmodule AuctionIndexer.Application do

  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      AuctionIndexer.Worker
    ]

    opts = [strategy: :one_for_one, name: AuctionIndexer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
