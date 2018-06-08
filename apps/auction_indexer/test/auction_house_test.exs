defmodule AuctionHouseTest do

  @moduledoc """
  Test module for AuctionHouse
  """

  use ExUnit.Case
  doctest AuctionIndexer.AuctionHouse
  alias AuctionIndexer.AuctionHouse
  alias Database.AuctionMessage

  # test "parses correct number of auctions" do
  #   path = Path.expand("test/fixtures")
  #   {:ok, raw0} = File.read("#{path}/2017-09-27.json")
  #   {:ok, raw1} = File.read("#{path}/2017-09-28.json")
  #   {:ok, raw2} = File.read("#{path}/2017-09-29.json")
  #   messages =
  #     Poison.decode!(raw0) ++ Poison.decode!(raw1) ++ Poison.decode!(raw2)
  #  		|> Enum.map(fn x -> AuctionMessage.from_raw_message(x) end)
  #   assert length(messages) > 0
  #   %{done: done} = AuctionHouse.process(%{active: %{}, done: []}, messages)
  #   sold_09_29 = Enum.filter(done, fn x ->
  #     date_string = DateTime.to_string(x.updated_at)
  #     x.sold == true and date_string >= "2017-09-29" and date_string <= "2017-09-30"
  #   end)
  #   assert length(sold_09_29) == 2603
  # end

end
