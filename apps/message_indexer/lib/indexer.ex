defmodule MessageIndexer.Indexer do

  @moduledoc """
  GenServer that handles mapping and storing of offical HEX API messages
  """

  use GenServer
  require Logger
  alias Database.{Repo, AuctionMessage}

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def process_message(message) do
    GenServer.cast(__MODULE__, {:process, message})
  end

  def handle_cast({:process, %{"MessageType" => "Auction"} = message}, state) do
    auction_message = AuctionMessage.from_raw_message(message)
    result = 
      auction_message
      |> AuctionMessage.to_changeset()
      |> Repo.insert()
    
    case result do
      {:error, %Ecto.Changeset{errors: [id: {"has already been taken", []}]}} ->
        Logger.warn("Already persisted auction message #{auction_message.id}: Skipping")
      {:error, changeset} ->
        Logger.error("Error when persisting auction message #{auction_message.id}: #{inspect changeset.errors}")
      _ -> :ok
    end
    {:noreply, state}
  end

  def handle_cast({:message, message}, state) do
    Logger.info("Dismissing message #{message["MessageId"]} of type #{message["MessageType"]}")
    {:noreply, state}
  end

end
