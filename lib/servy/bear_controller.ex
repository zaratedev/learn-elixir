defmodule Servy.BearController do

  alias Servy.Bear
  alias Servy.Wildthings

  def index(conv) do
    items =
      Wildthings.list_bears()
      |> Enum.filter(fn (b) -> b |> Bear.is_grizzly end)
      |> Enum.sort(fn (b1, b2) -> Bear.order_asc_by_name(b1, b2) end)
      |> Enum.map(fn (bear) -> bear |> bear_item end)
      |> Enum.join

    %{conv | status: 200, resp_body: "<ul>#{items}</ul>"}
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    %{conv | status: 200, resp_body: "<h1>Bear #{bear.id}: #{bear.name}</h1>"}
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{conv | status: 200, resp_body: "Created a #{type} bear named #{name}"}
  end

  defp bear_item(bear) do
    "<li>#{bear.name} - #{bear.type}</li>"
  end
end
