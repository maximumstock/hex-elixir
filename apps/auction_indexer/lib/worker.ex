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
  alias Database.{AuctionMessage, Auction}

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
        x |> AuctionIndexer.EventParser.parse_event(message) |> process()
      end)
      AuctionMessage.mark_as_processed(message)
      run()
    end
  end

  defp process({:new, new_auction}) do
    Database.Repo.insert(new_auction)
  end

  defp process({:bid, auction_id, new_bid, bid_timestamp}) do
    auction = Database.Repo.get(Auction, auction_id)
    if auction do
      change = %{
        bids: auction.bids ++ [%{price: new_bid, created_at: bid_timestamp}],
        updated_at: DateTime.utc_now(),
        current_bid: new_bid
      }
      Auction.patch_auction_if_exists(auction_id, change)
    end
  end

  defp process({:buyout, auction_id, new_buyout, updated_at}) do
    change = %{
      price: new_buyout,
      updated_at: updated_at
    }
    Auction.patch_auction_if_exists(auction_id, change)
  end

  defp process({:sold, auction_id, type, updated_at}) do
    change = %{
      sold: true,
      active: false,
      type: type,
      updated_at: updated_at
    }
    Auction.patch_auction_if_exists(auction_id, change)
  end

  defp process({:closed, auction_id, type, updated_at}) do
    auction = Database.Repo.get(Auction, auction_id)
    if auction do
      change = %{
        sold: length(auction.bids) > 0,
        active: false,
        type: type,
        updated_at: updated_at
      }
      Auction.patch_auction_if_exists(auction_id, change)
    end
  end

end
