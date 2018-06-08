defmodule MessageIndexer.Indexer do

  @moduledoc """
  Module for handling HEX API messages
  """

  require Logger
  alias Database.{Repo, AuctionMessage}

  def process_message(%{"MessageType" => "Auction"} = message) do
    auction_message = AuctionMessage.from_raw_message(message)
    result = message
      |> AuctionMessage.from_raw_message()
      |> AuctionMessage.to_changeset()
      |> Repo.insert()

    case result do
      {:error, %Ecto.Changeset{errors: [id: {"has already been taken", []}]}} ->
        Logger.warn("Already persisted auction message #{auction_message.id}: Skipping")
      {:error, changeset} ->
        Logger.error("Error when persisting auction message #{auction_message.id}: #{inspect changeset.errors}")
      _ -> :ok
    end
  end

  def process_message(message) do
    Logger.info("Dismissing message #{message["MessageId"]} of type #{message["MessageType"]}")
  end

end
