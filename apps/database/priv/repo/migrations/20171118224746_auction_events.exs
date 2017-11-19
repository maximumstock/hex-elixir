defmodule Database.Repo.Migrations.AuctionEvents do
  use Ecto.Migration

  def up do
    create table("auction_events") do
      add :type, :string
      add :message_id, :string
      add :data, :map
      add :was_processed, :boolean
      add :last_processed_at, :utc_datetime
      add :created_at, :utc_datetime
    end
  end

  def down do
    drop table("auction_events")
  end
end
