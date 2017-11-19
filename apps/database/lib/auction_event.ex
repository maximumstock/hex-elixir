defmodule Database.AuctionEvent do

  @moduledoc """
  Schema module for auction events
  """

  use Ecto.Schema, Timex
  import Ecto.Query

  @required_fields [:message_id, :type, :data, :created_at]
  @optional_fiels  [:was_processed, :last_processed_at]

  schema "auction_events" do
    field :message_id, :string
    field :type, :string
    field :data, :map
    field :created_at, :utc_datetime
    # optional
    field :was_processed, :boolean, default: false
    field :last_processed_at, :utc_datetime, default: nil
  end

  def to_changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, @required_fields ++ @optional_fiels)
    |> Ecto.Changeset.validate_required(@required_fields)
    |> Ecto.Changeset.unique_constraint(:id, [name: :events_pkey])
  end

  def from_raw(raw_message, raw_event) do
    %__MODULE__{
      message_id: raw_message["MessageId"],
      type: raw_message["MessageType"],
      created_at: parse_datetime(raw_message["MessageTime"]),
      data: raw_event
    }
  end

  def get_next_event do
    Database.Event
    |> where([type: "Auction", was_processed: false])
    |> order_by([asc: :created_at])
    |> first()
    |> Database.Repo.one()
  end

  def mark_as_processed(event) do
    change = %{was_processed: true, last_processed_at: DateTime.utc_now()}
    event
    |> Ecto.Changeset.cast(change, Map.keys(change))
    |> Database.Repo.update()
  end

  def parse_datetime(datetime) do
    datetime
    |> Timex.parse!("{M}/{D}/{YYYY} {h12}:{m}:{s} {AM}")
    |> Timex.to_datetime("Etc/UTC")
  end

end
