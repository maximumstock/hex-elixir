defmodule MessageIndexer.Indexer do

  @moduledoc """
  Logic that handles mapping and storing of offical HEX API messages
  """

  require Logger
  alias Database.{Repo, AuctionEvent}

  def process_message(%{"MessageType" => "Auction"} = message) do
    message["Events"]
    |> Enum.map(&AuctionEvent.from_raw(message, &1))
    |> Enum.each(&Repo.insert/1)
  end

  def process_message(%{"MessageId" => message_id, "MessageType" => type}) do
    Logger.info("Dismissing message #{message_id} of type #{type}}")
  end

  def process_message(_) do
    Logger.warn("Message Indexer received something unusable")
  end

end
