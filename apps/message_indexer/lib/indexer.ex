defmodule MessageIndexer.Indexer do

  @moduledoc """
  Handles all parsed messages from the official HEX API
  """

  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_message(message) do
    GenServer.cast(__MODULE__, {:message, message})
  end

  def handle_cast({:message, %{"MessageType" => "Auction"} = message}, state) do
    message = %Database.Schema.Message{
      id: message["MessageId"],
      type: message["MessageType"],
      created_at: Database.Schema.Message.parse_datetime(message["MessageTime"]),
      events: message["Events"]
    }
    changeset = Database.Schema.Message.to_changeset(message)
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
