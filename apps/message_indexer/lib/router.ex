defmodule MessageIndexer.Router do
  use Plug.Router
  require Logger
  alias MessageIndexer.Indexer

  plug :match
  plug :dispatch

  def child_spec(_opts) do
    port = Application.get_env(:message_indexer, :port) |> parse_port()
    Logger.info("Starting Cowboy HTTP listener on port #{port}")
    Plug.Adapters.Cowboy.child_spec(:http, __MODULE__, [], [port: port])
  end

  post "/" do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    
    body
    |> Poison.decode!
    |> Indexer.process_message

    send_resp(conn, 200, "ok")
  end

  defp parse_port(port) when is_integer(port), do: port
  defp parse_port(port), do: port |> String.to_integer

end
