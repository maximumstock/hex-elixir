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
  alias Database.{Repo, AuctionMessage, Auction}
  alias AuctionIndexer.EventParser

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
    messages = AuctionMessage.get_next_messages(1)
    if length(messages) == 1 do
      message = List.first(messages)
      Logger.info("Processing new auction message #{message.id}")
      Enum.each(message.events, fn event ->
        auction = Repo.get(Auction, event["AuctionId"])
        parsed_event = EventParser.parse_event(event, message.created_at, auction)
        process(parsed_event)
      end)
      AuctionMessage.mark_as_processed(message)
      run()
    end
  end

  defp process(:ignore), do: nil
  # ignore primary key constraint errors
  defp process({:new, changeset}) do
    Repo.insert(changeset, [on_conflict: :nothing])
  end
  defp process({_, changeset}), do: Repo.update(changeset)

end
