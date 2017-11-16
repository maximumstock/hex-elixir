defmodule Database.Schema.Message do
  use Ecto.Schema, Timex

  @fields [:id, :type, :events, :created_at]
  @primary_key {:id, :string, autogenerate: false}

  schema "messages" do
    field :type, :string
    field :events, {:array, :map}
    field :was_processed, :boolean, default: false
    field :last_processed_at, :utc_datetime
    field :created_at, :utc_datetime
  end

  def to_changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, @fields)
    |> Ecto.Changeset.validate_required(@fields)
    |> Ecto.Changeset.unique_constraint(:id, [name: :messages_pkey])
  end

  defp parse_datetime(datetime) do
    datetime
    |> Timex.parse!(datetime, "{D}/{M}/{YYYY} {h12}:{m}:{s} {AM}")
    |> Timex.to_datetime("Etc/UTC")
    |> Timex.format("{ISO:Extended}")
  end

end
