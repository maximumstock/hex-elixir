defmodule Database.Repo.Migrations.Auctions do
  use Ecto.Migration

  def up do
    create table("auctions", [primary_key: false]) do
      add :id, :string, [primary_key: true]
      add :item_uuid, :string
      add :initial_buyout, :integer
      add :initial_bid, :integer
      add :current_bid, :integer
      add :currency, :string
      add :type, :string, default: nil
      add :price, :integer, default: 0
      add :sold, :boolean, default: false
      add :active, :boolean, default: true
      add :bids, {:array, :map}, default: []
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end
  end

  def down do
    drop table("auctions")
  end
end
