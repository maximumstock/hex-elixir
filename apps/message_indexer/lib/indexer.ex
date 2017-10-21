defmodule MessageIndexer.Indexer do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_message(message) do
    GenServer.cast(__MODULE__, {:message, message})
  end

  def handle_cast({:message, message}, state) do
    message = %Database.Schema.Message{
      id: message["MessageId"],
      type: message["MessageType"],
      created_at: DateTime.utc_now(),
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

end
