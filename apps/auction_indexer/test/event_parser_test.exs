defmodule EventParserTest do

  @moduledoc """
  Test module for EventParser
  """

  use ExUnit.Case
  doctest AuctionIndexer.EventParser
  alias AuctionIndexer.EventParser
  alias Database.AuctionMessage

  """
  one test per parse_event branch
  """

  test "parse new auction" do
    message = %{
      "AuctionId" => "some-id",
      "Item" => "some-item-uuid",
      "Action" => "POST"
    }

    {:new, %{}} = EventParser.parse_event(message, "some-timestamp", nil)
  end

end
