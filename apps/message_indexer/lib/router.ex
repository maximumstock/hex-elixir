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
    {:ok, body} = parse_body(conn)
    
    # Processing takes place in web process, because we 
    # don't need the scaling in live scenarios and this way
    # we don't have to do anything for parallelized indexing
    case Poison.decode(body) do
      {:ok, json} -> Indexer.process_message(json)
      {:error, reason} -> Logger.error("Error when parsing POST request: #{reason}")
    end

    send_resp(conn, 200, "ok")
  end

  defp parse_body(conn, acc \\ []) do
    case Plug.Conn.read_body(conn) do
      {:ok, body, conn}   -> {:ok, Enum.join(acc ++ [body], "")}
      {:more, data, conn} -> parse_body(conn, acc ++ [data])
      error               -> error
    end
  end

  defp parse_port(port) when is_integer(port), do: port
  defp parse_port(port), do: port |> String.to_integer

end
