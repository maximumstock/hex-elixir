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
  def parse_event(%{"Action" => "POST"} = event, message, _auction) do
    parse_new_auction(event, message)
  end

  @doc """
  Ignore all events there is no auction for (other than new auctions)
  """
  def parse_event(_event, _message, nil), do: :ignore

  @doc """
  `SOLD` and `CLOSE` handlers -> just export the corresponding auctions as sales
  """
  def parse_event(%{"Action" => "SOLD"} = _event, message, auction) do
    change = %{
      updated_at: message.created_at,
      type: "Buyout",
      sold: true,
      active: false
    }
    Database.Auction.to_changeset(auction, change)
  end

  def parse_event(%{"Action" => "CLOSE"} = _event, message, auction) do
    change = %{
      updated_at: message.created_at,
      type: parse_closing_type(auction),
      active: false,
      sold: Database.Auction.was_bid_on?(auction),
      price: parse_closing_price(auction)
    }
    Database.Auction.to_changeset(auction, change)
  end

  @doc """
  `BID` and `BUYOUT` handlers -> how did the price/bids for this auction change?
  """
  def parse_event(%{"Action" => "BID"} = event, message, auction) do
    new_bid = parse_bid(event)
    change = %{
      updated_at: message.created_at,
      bids: auction.bids ++ [%{price: new_bid, created_at: message.created_at}],
      current_bid: new_bid
    }
    Database.Auction.to_changeset(auction, change)
  end

  def parse_event(%{"Action" => "BUYOUT"} = event, message, auction) do
    change = %{
      updated_at: message.created_at,
      price: parse_buyout(event)
    }
    Database.Auction.to_changeset(auction, change)
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

  defp parse_buyout(%{"PlatBuyout" => "0", "GoldBuyout" => val}), do: String.to_integer(val)
  defp parse_buyout(%{"PlatBuyout" => val, "GoldBuyout" => "0"}), do: String.to_integer(val)

  defp parse_bid(%{"PlatBid" => "0", "GoldBid" => val}), do: String.to_integer(val)
  defp parse_bid(%{"PlatBid" => val, "GoldBid" => "0"}), do: String.to_integer(val)

  defp parse_currency(%{"PlatBuyout" => pbuy, "PlatBid" => pbid}) when pbuy != "0" or pbid != "0", do: "Platinum"
  defp parse_currency(%{"GoldBuyout" => gbuy, "GoldBid" => gbid}) when gbuy != "0" or gbid != "0", do: "Gold"

  defp parse_closing_price(auction) do
    case Database.Auction.was_bid_on?(auction) do
      false -> nil
      true -> auction.bids |> List.last() |> Map.get("price", nil)
    end
  end

  defp parse_closing_type(auction) do
    case Database.Auction.was_bid_on?(auction) do
      false -> nil
      true  -> "Bid"
    end
  end

end
