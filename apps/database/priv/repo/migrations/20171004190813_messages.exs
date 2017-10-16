defmodule Database.Repo.Migrations.Messages do
  use Ecto.Migration

  def up do
    create table("messages", [primary_key: false]) do
      add :id, :string, [primary_key: true]
      add :type, :string
      add :events, :map
      add :was_processed, :boolean
      add :last_processed_at, :utc_datetime
      add :created_at, :utc_datetime
    end
  end

  def down do
    drop table("messages")
  end

end
