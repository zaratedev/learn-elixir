defmodule Servy.Handler do
  @moduledoc "Hanldes HTTP requests."

  alias Servy.VideoCam
  # alias Servy.Fetcher
  alias Servy.Conv, as: Conv
  alias Servy.BearController

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  # def route(conv) do
  #   route(conv, conv.method, conv.path)
  # end

  # Function Clauses
  def route(%Conv{ method: "POST", path: "/pledges" } = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{ method: "GET", path: "/pledges" } = conv) do
    Servy.PledgeController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/snapshots" } = conv) do
    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam3"]
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    bigfoot = Task.await(task)

    %{conv | status: 200, resp_body: inspect({snapshots, bigfoot})}
  end

  def route(%Conv{ method: "GET", path: "/kaboom" }) do
    raise "Kaboom!"
  end

  def route(%Conv{ method: "GET", path: "/hibernate/" <> time } = conv) do
    time |> String.to_integer |> :timer.sleep
    %{conv | status: 200, resp_body: "Awake"}
  end

  def route(%Conv{ method: "GET", path: "/wildthings" } = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{ method: "GET", path: "/api/bears" } = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears" } = conv) do
    BearController.index(conv)
  end

  def route(%Conv{ method: "POST", path: "/bears" } = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "GET", path: "/about" } = conv) do
    @pages_path
      |> Path.join("about.html")
      |> File.read
      |> handler_file(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{ path: path } = conv) do
    %{conv | status: 404, resp_body: "No #{path} here"}
  end

  def format_response(%Conv{} = conv) do
    # TODO: Use values in the map to create an HTTP response
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_content_type}\r
    Content-Length: #{String.length(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end

  def handler_file({:ok, content}, conv) do
    %{ conv | status: 200, resp_body: content }
  end

  def handler_file({:error, :enoent}, conv) do
    %{ conv | status: 404, resp_body: "File not found"}
  end

  def handler_file({:error, reason}, conv) do
    %{conv | status: 500, resp_body: "File error #{reason}"}
  end
end
