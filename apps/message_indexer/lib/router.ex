defmodule MessageIndexer.Router do
  use Plug.Router
  alias MessageIndexer.Indexer

  plug :match
  plug :dispatch

  def child_spec(opts) do
    port = Application.get_env(:message_indexer, :port)
    port = 
      case is_integer(port) do
        true -> port
        false -> port |> String.to_integer
      end
    Plug.Adapters.Cowboy.child_spec(:http, __MODULE__, [], [port: port])
  end

  post "/" do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    
    body
    |> Poison.decode!
    |> Indexer.handle_message

    send_resp(conn, 200, "ok")
  end

end
