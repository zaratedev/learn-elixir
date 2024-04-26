defmodule Servy.VideoCam do
  def get_snapshot(camare_cam) do
    :timer.sleep(1000)

    "#{camare_cam}-snapshot.jpg"
  end
end
