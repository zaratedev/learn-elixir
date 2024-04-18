defmodule Servy.Handler do
  def handle(request) do
    # conv = parse(request)
    # conv = route(conv)
    # format_response(conv)

    # Operator Pipe

    request
    |> parse
    |> route
    |> format_response
  end

  def parse(request) do
    conv = %{ method: "GET", path: "/wildthings", resp_body: ""}
  end

  def route(conv) do
    conv = %{ method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers"}
  end

  def format_response(conv) do
    # TODO: Use values in the map to create an HTTP response
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 20

    Bears, Lions, Tigers
    """
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
