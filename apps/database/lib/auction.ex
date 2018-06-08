defmodule Database.Auction do

  @moduledoc """
  Schema module for auctions
  """

  use Ecto.Schema
  alias Ecto.Changeset

  @fields [:id, :item_uuid, :initial_buyout, :initial_bid, :current_bid,
    :currency, :type, :price, :sold, :active, :bids, :created_at, :updated_at]
  @primary_key {:id, :string, autogenerate: false}

  schema "auctions" do
    field :item_uuid, :string
    field :initial_buyout, :integer
    field :initial_bid, :integer
    field :current_bid, :integer, default: nil
    field :currency, :string
    field :type, :string, default: nil
    field :price, :integer, default: 0
    field :sold, :boolean, default: false
    field :active, :boolean, default: true
    field :bids, {:array, :map}, default: []
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
  end

  def to_changeset(struct, params \\ %{}) do
    struct
    |> Changeset.cast(params, @fields)
    |> Changeset.validate_required(@fields)
    |> Changeset.unique_constraint(:id, [name: :auctions_pkey])
  end

  def was_bid_on?(%__MODULE__{bids: []}), do: false
  def was_bid_on?(%__MODULE__{bids: _bids}), do: true

end
