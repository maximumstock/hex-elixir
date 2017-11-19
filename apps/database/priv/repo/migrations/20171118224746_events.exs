defmodule Database.Repo.Migrations.Events do
  use Ecto.Migration

  def up do
    create table("events") do
      add :type, :string
      add :message_id, :string
      add :data, :map
      add :was_processed, :boolean
      add :last_processed_at, :utc_datetime
      add :created_at, :utc_datetime
    end
  end

  def down do
    drop table("events")
  end
end
