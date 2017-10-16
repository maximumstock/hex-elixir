defmodule Database.Schema.Auction do
  use Ecto.Schema

  @fields [:id, :item_uuid, :initial_buyout, :initial_bid, :current_bid, :currency, :type, :price, :sold, :bids, :created_at, :updated_at]
  @primary_key {:id, :string, autogenerate: false}

  schema "auctions" do
    field :item_uuid, :string
    field :initial_buyout, :integer
    field :initial_bid, :integer
    field :current_bid, :integer
    field :currency, :string
    field :type, :string, default: "tbd"
    field :price, :integer, default: 0
    field :sold, :boolean, default: false
    field :bids, {:array, :map}, default: []
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
  end

  def to_changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, @fields)
    |> Ecto.Changeset.validate_required(@fields)
    |> Ecto.Changeset.unique_constraint(:id, [name: :auctions_pkey])
  end

end
