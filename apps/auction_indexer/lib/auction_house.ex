defmodule AuctionIndexer.AuctionHouse do
  
  @moduledoc """
  In-memory version of the auction house, 
  manually fed by APi messages
  """

  alias AuctionIndexer.EventParser

  def process_message(state, %Database.AuctionMessage{} = message) do
    process_message(state, message.events, message.created_at)
  end

  defp process_message(state, [], _timestamp), do: state
  defp process_message(state, events, timestamp) do
    [next | rest] = events
    existing_auction = Map.get(state.active, next["AuctionId"])
    result = EventParser.parse_event(next, timestamp, existing_auction)
    new_state = process_event(state, result, existing_auction)
    process_message(new_state, rest, timestamp)
  end

  defp process_event(state, :ignore, _existing_auction), do: state
  defp process_event(state, {:new, new_auction} = _parsed_event, _existing_auction), do: update_record(state, new_auction, %{})
  defp process_event(state, _parsed_event, nil), do: state
  defp process_event(state, {:bid,    changeset}, existing_auction),  do: update_record(state, existing_auction, changeset.changes)
  defp process_event(state, {:buyout, changeset}, existing_auction),  do: update_record(state, existing_auction, changeset.changes)
  defp process_event(state, {_,   changeset}, existing_auction),  do: add_done_auction(state, existing_auction, changeset.changes)

  defp update_record(state, existing_auction, changes) do
    updated_auction = Map.merge(existing_auction, changes)
    %{state | active: Map.put(state.active, updated_auction.id, updated_auction)}
  end

  defp add_done_auction(state, existing_auction, changes) do
    new_active = Map.delete(state.active, existing_auction.id)
    done_auction = Map.merge(existing_auction, changes)
    %{active: new_active, done: state.done ++ [done_auction]}
  end

end
