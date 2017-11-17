defmodule MessageIndexer.Indexer do

  @moduledoc """
  Handles all parsed messages from the official HEX API
  """

  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def process_message(message) do
    GenServer.cast(__MODULE__, {:process, message})
  end

  def handle_cast({:process, %{"MessageType" => "Auction"} = message}, state) do
    message = %Database.AuctionMessage{
      id: message["MessageId"],
      type: message["MessageType"],
      created_at: Database.AuctionMessage.parse_datetime(message["MessageTime"]),
      events: message["Events"]
    }
    changeset = Database.AuctionMessage.to_changeset(message)
    if changeset.valid? == true do
      Database.Repo.insert(changeset)
    else
      Logger.error("Cannot persist message #{inspect message}, #{inspect changeset.errors}")      
    end
    {:noreply, state}
  end

  def handle_cast({:message, message}, state) do
    Logger.info("Dismissing message #{message["MessageId"]} of type #{message["MessageType"]}")
    {:noreply, state}
  end

end
