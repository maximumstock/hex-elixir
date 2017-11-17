defmodule AuctionIndexer.Worker do

  @moduledoc """
  This module describes a GenServer-based logic implementation
  based on AuctionIndexer.EventParser to manipulate the auctions/sales 
  tables through the Database application.

  1. Scan database for unprocessed API messages and take the next one in
    chronological order
  2. Process the message and update the database based on mapped rules 
    from AuctionIndexer.EventParser
  3. Repeat until no messages are left and sleep a minute.
  """

  use GenServer
  require Logger
  alias Database.AuctionMessage

  @reschedule_delay 30_000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    schedule(0)
    {:ok, []}
  end

  def schedule(delay) do
    Process.send_after(self(), :run, delay)
  end

  def handle_info(:run, state) do
    schedule(@reschedule_delay)
    run()
    {:noreply, state}
  end

  def run do
    message = AuctionMessage.get_next_message()
    if message do
      Logger.info("Processing new auction message #{message.id}")
      Enum.each(message.events, fn x ->
        x |> AuctionIndexer.EventParser.parse_event(message) |> handle_event()
      end)
      mark_as_processed(message)
      run()
    end
  end

  defp handle_event({:new, new_auction}) do
    Logger.info("Insert new auction")
    Database.Repo.insert(new_auction)
  end

  defp handle_event({:bid, auction_id, new_bid, bid_timestamp}) do
    auction = Database.Repo.get(Database.Auction, auction_id)
    if auction do
      Logger.info("Updating auction #{auction_id}: bid -> #{new_bid}")     
      Database.Auction.to_changeset(auction, %{
        bids: auction.bids ++ [%{price: new_bid, created_at: bid_timestamp}],
        updated_at: DateTime.utc_now(),
        current_bid: new_bid
      }) |> Database.Repo.update
    end
  end

  defp handle_event({:buyout, auction_id, new_buyout}) do
    auction = Database.Repo.get(Database.Auction, auction_id)
    if auction do
      Logger.info("Updating auction #{auction_id}: buyout -> #{new_buyout}")
      auction
      |> Database.Auction.to_changeset(%{
        price: new_buyout,
        updated_at: DateTime.utc_now()
      }) 
      |> Database.Repo.update
    end
  end

  defp handle_event({:sold, auction_id, type}) do
    auction = Database.Repo.get(Database.Auction, auction_id)
    if auction do
      mark_auction_as_inactive(auction, type, true)
    end
  end

  defp handle_event({:closed, auction_id, type}) do
    auction = Database.Repo.get(Database.Auction, auction_id)
    if auction do
      if length(auction.bids) > 0 do
        mark_auction_as_inactive(auction, type, true)
      else
        mark_auction_as_inactive(auction, type, false)
      end
    end
  end

  defp mark_auction_as_inactive(auction, type, sold) do
    auction
    |> Database.Auction.to_changeset(%{
      sold: sold,
      active: false,
      type: type,
      updated_at: DateTime.utc_now()
    }) |> Database.Repo.update
  end

  defp mark_as_processed(message) do
    change = %{was_processed: true, last_processed_at: DateTime.utc_now()}
    
    message
    |> Ecto.Changeset.cast(change, Map.keys(change))
    |> Database.Repo.update()
  end


end
