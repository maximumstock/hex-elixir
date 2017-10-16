defmodule MessageIndexer.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  def child_spec(opts) do
    port = Application.get_env(:message_indexer, :port)
    Plug.Adapters.Cowboy.child_spec(:http, __MODULE__, [], [port: port])
  end

  post "/" do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    
    body
    |> Poison.decode!
    |> MessageIndexer.Indexer.handle_message

    send_resp(conn, 200, "ok")
  end

end
