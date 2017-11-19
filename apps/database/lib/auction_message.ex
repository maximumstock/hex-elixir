defmodule Database.AuctionMessage do

  @moduledoc """
  Schema module for auction messages
  """

  use Ecto.Schema, Timex
  import Ecto.Query

  @required_fields [:id, :type, :events, :created_at]
  @optional_fiels  [:was_processed, :last_processed_at]
  @primary_key {:id, :string, autogenerate: false}

  schema "messages" do
    field :type, :string
    field :events, {:array, :map}
    field :created_at, :utc_datetime
    # optional
    field :was_processed, :boolean, default: false
    field :last_processed_at, :utc_datetime, default: nil
  end

  def to_changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, @required_fields ++ @optional_fiels)
    |> Ecto.Changeset.validate_required(@required_fields)
    |> Ecto.Changeset.unique_constraint(:id, [name: :messages_pkey])
  end

  def from_raw_message(raw_message) do
    %__MODULE__{
      id: raw_message["MessageId"],
      type: raw_message["MessageType"],
      created_at: parse_datetime(raw_message["MessageTime"]),
      events: raw_message["Events"]
    }
  end

  def get_next_messages(limit \\ 1) do
    Database.AuctionMessage
    |> where([type: "Auction", was_processed: false])
    |> order_by([asc: :created_at])
    |> limit(^limit)
    |> Database.Repo.all()
  end

  def mark_as_processed(message) do
    change = %{was_processed: true, last_processed_at: DateTime.utc_now()}
    message
    |> Ecto.Changeset.cast(change, Map.keys(change))
    |> Database.Repo.update()
  end

  def parse_datetime(datetime) do
    datetime
    |> Timex.parse!("{M}/{D}/{YYYY} {h12}:{m}:{s} {AM}")
    |> Timex.to_datetime("Etc/UTC")
  end

end
