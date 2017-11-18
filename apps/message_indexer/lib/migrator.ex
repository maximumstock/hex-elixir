defmodule MessageIndexer.Migrator do

  @moduledoc """
  Helper module to migrate existing messages through
  the message indexer web interface
  """

  def run_all(directory) do
    {:ok, files} = File.ls(directory)
    files
    |> Enum.map(fn file -> "#{directory}/#{file}" end)
    |> Enum.each(&run/1)
  end

  def run(filepath) do
    IO.puts("Reading file #{filepath}")
    {:ok, raw_binary} = File.read(filepath)
    {:ok, json} = Poison.decode(to_string(raw_binary))
    Enum.each(json, &__MODULE__.send/1)
  end

  def send(%{"MessageType" => "Auction"} = message), do: MessageIndexer.Indexer.process_message(message)
  def send(_), do: nil

end
