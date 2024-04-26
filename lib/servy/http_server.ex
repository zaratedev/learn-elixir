defmodule Servy.HttpServer do
  @doc """
  Starts the server on the given `port` of localhost.
  """
  def start(port) when is_integer(port) and port > 1023 do
    # Creates a socket to listen for client connections.
    # `listen_socket` is bound to the listenting socket.
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    IO.puts "\nListening for connection requests on port #{port}..."

    accept_loop(listen_socket)
  end

  def accept_loop(listen_socket) do
    IO.puts "Waiting to accept a client connection..."

    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    IO.puts "Connection accepted!"

    spawn(fn -> server(client_socket) end)

    accept_loop(listen_socket)
  end

  def server(client_socket) do
    IO.puts "#{inspect self()}: Working on it!"

    client_socket
    |> read_request
    |> Servy.Handler.handle
    |> write_response(client_socket)
  end

  def read_request(client_socket) do
    {:ok, request} = :gen_tcp.recv(client_socket, 0) # All available bytes

    IO.puts "Received request:\n"

    IO.puts request

    request
  end

  def generate_response(_request) do
    """
    HTTP/1.1 200 OK\r
    Content-Type: text/plain\r
    Content-Length: 6\r
    \r
    Hello
    """
  end

  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    IO.puts "Sent response:\n"
    IO.puts response

    :gen_tcp.close(client_socket)
  end
end
