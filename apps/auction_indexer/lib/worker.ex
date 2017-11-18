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
      Enum.each(message.events, fn event ->
        auction = Database.Repo.get(Auction, event["AuctionId"])
        AuctionIndexer.EventParser.parse_event(event, message, auction) |> process()
      end)
      AuctionMessage.mark_as_processed(message)
      run()
    end
  end

  defp process(:ignore), do: nil
  defp process({:new, changeset}), do: Database.Repo.insert(changeset)
  defp process(changeset), do: Database.Repo.update(changeset)

end
