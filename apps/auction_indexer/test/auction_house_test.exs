defmodule AuctionHouseTest do

  @moduledoc """
  Test module for AuctionHouse
  """

  use ExUnit.Case
  doctest AuctionIndexer.AuctionHouse
  alias AuctionIndexer.AuctionHouse
  alias Database.AuctionMessage

  test "parses correct number of auctions" do
    path = Path.expand("test/fixtures")
    {:ok, raw1} = File.read("#{path}/2017-09-28.json")
    {:ok, raw2} = File.read("#{path}/2017-09-29.json")
    messages =
      Poison.decode!(raw1) ++ Poison.decode!(raw2)
   		|> Enum.map(fn x -> AuctionMessage.from_raw_message(x) end) 
    assert length(messages) > 0
    starting_state = %{active: %{}, done: []}
    ah_state = AuctionHouse.process(starting_state, messages)
    assert length(ah_state.done) > 0
    IO.inspect(length(ah_state.done))
  end
  
end
