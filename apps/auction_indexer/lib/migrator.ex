defmodule AuctionIndexer.Migrator do
  
  @moduledoc false

  alias AuctionIndexer.AuctionHouse
  alias Database.Repo

  def start() do
    migrate(%{active: %{}, sold: []}, [])
  end

  defp migrate(state, []) do
    # Before requesting the next batch, insert all sold auctions
    persist(state.sold)
    message_batch = Database.AuctionMessage.get_next_messages(200)
    # Remove sold auctions that were just persisted
    migrate(%{state | sold: []}, message_batch)    
  end
  defp migrate(state, [next | rest]) do
    new_state = AuctionHouse.process_message(state, next)
    Database.AuctionMessage.mark_as_processed(next)
    migrate(new_state, rest)
  end

  defp persist(list) do
    list = Enum.map(list, fn x -> 
      x = Map.from_struct(x)
      Map.delete(x, :__meta__)
    end)
    Repo.insert_all(Database.Auction, list)
  end

end
