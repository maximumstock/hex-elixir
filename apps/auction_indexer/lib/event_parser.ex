defmodule AuctionIndexer.EventParser do

  @moduledoc """
  This module exposes functions for parsing auction events.
  Each event is mapped to some internal tuple that describes
  the changes for a given auction that the event data
  contains. That tuple is interpreted by some an instance of
  AuctionIndexer.Worker to update the database accordingly.
  """

  @doc """
  This handles newly created auctions
  """
  def parse_event(%{"Action" => "POST"} = event, message) do
    parse_new_auction(event, message)
  end

  @doc """
  `SOLD` and `CLOSE` handlers -> just export the corresponding auctions as sales
  """
  def parse_event(%{"Action" => "SOLD"} = event, message) do
    {:sold, event["AuctionId"], parse_type(event), message.created_at}
  end

  def parse_event(%{"Action" => "CLOSE"} = event, message) do
    {:closed, event["AuctionId"], parse_type(event), message.created_at}
  end

  @doc """
  `BID` and `BUYOUT` handlers -> how did the price/bids for this auction change?
  """
  def parse_event(%{"Action" => "BID"} = event, message) do
    {:bid, event["AuctionId"], parse_bid(event), message.created_at}
  end

  def parse_event(%{"Action" => "BUYOUT"} = event, message) do
    {:buyout, event["AuctionId"], parse_buyout(event), message.created_at}
  end

  defp parse_new_auction(%{"AuctionId" => id, "Item" => item_uuid} = event, message) do
    new_auction = %Database.Auction{
      id: id,
      active: true,
      item_uuid: item_uuid,
      initial_buyout: parse_buyout(event),
      initial_bid: parse_bid(event),
      current_bid: parse_bid(event),
      currency: parse_currency(event),
      created_at: message.created_at,
      updated_at: message.created_at
    }
    {:new, new_auction}
  end

  defp parse_type(%{"Action" => "SOLD"}), do: "Buyout"
  defp parse_type(%{"Action" => "CLOSE"}), do: "Bid"

  defp parse_buyout(%{"PlatBuyout" => "0", "GoldBuyout" => val}), do: String.to_integer(val)
  defp parse_buyout(%{"PlatBuyout" => val, "GoldBuyout" => "0"}), do: String.to_integer(val)

  defp parse_bid(%{"PlatBid" => "0", "GoldBid" => val}), do: String.to_integer(val)
  defp parse_bid(%{"PlatBid" => val, "GoldBid" => "0"}), do: String.to_integer(val)

  defp parse_currency(%{"PlatBuyout" => pbuy, "PlatBid" => pbid}) when pbuy != "0" or pbid != "0", do: "Platinum"
  defp parse_currency(%{"GoldBuyout" => gbuy, "GoldBid" => gbid}) when gbuy != "0" or gbid != "0", do: "Gold"

end
