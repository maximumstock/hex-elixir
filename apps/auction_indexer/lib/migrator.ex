defmodule AuctionIndexer.Migrator do

  @moduledoc false

  alias AuctionIndexer.AuctionHouse
  alias Database.{Repo, AuctionMessage, Auction}

  def start, do: migrate(%{active: %{}, done: []})
  def start(state), do: migrate(state)

  defp migrate(state) do
    message_batch = AuctionMessage.get_next_messages(100)
    new_state = parse_messages(state, message_batch)
    persist(new_state.done)
    AuctionMessage.mark_as_processed(message_batch)

    if length(message_batch) > 0 do
      migrate(%{new_state | done: []})
    end
  end

  defp parse_messages(state, []), do: state
  defp parse_messages(state, [next | rest]) do
    new_state = AuctionHouse.process_message(state, next)
    parse_messages(new_state, rest)
  end

  defp persist([]), do: :ok
  defp persist(list) do
    {batch, rest} = Enum.split(list, 5000)
    batch = Enum.map(batch, fn x ->
      x = Map.from_struct(x)
      Map.delete(x, :__meta__)
    end)
    Repo.insert_all(Auction, batch)
    persist(rest)
  end

end
