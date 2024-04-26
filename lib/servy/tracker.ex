defmodule Servy.Tracker do
  def get_location(wildthing) do
    :timer.sleep(500)

    locations = %{
      "roscoe" => %{lat: "44.3242 N", lng: "110.4323 W"},
      "smokey" => %{lat: "44.3242 N", lng: "110.4323 W"},
      "brutus" => %{lat: "44.3242 N", lng: "110.4323 W"},
      "bigfoot" => %{lat: "44.3242 N", lng: "110.4323 W"}
    }

    Map.get(locations, wildthing)
  end
end
