defmodule AuctionIndexer.Migrator do
  
  @moduledoc false

  alias AuctionIndexer.AuctionHouse
  alias Database.Repo

  def start() do
    migrate(%{active: %{}, done: []}, [])
  end

  defp migrate(state, []) do
    # Before requesting the next batch, insert all done auctions
    persist(state.done)
    message_batch = Database.AuctionMessage.get_next_messages(50)
    # Remove done auctions that were just persisted
    migrate(%{state | done: []}, message_batch)
  end
  defp migrate(state, [next | rest]) do
    new_state = AuctionHouse.process_message(state, next)
    Database.AuctionMessage.mark_as_processed(next)
    migrate(new_state, rest)
  end

  defp persist([]), do: :ok
  defp persist(list) do
    {batch, rest} = Enum.split(list, 1000)
    batch = Enum.map(batch, fn x -> 
      x = Map.from_struct(x)
      Map.delete(x, :__meta__)
    end)
    Repo.insert_all(Database.Auction, batch)
    persist(rest)
  end

end
