defmodule RecipeCrawlers.Consumer do
  use GenStage

  def start_link() do
    GenStage.start_link(RecipeCrawlers.Consumer, :ok)
  end

  def init(:ok) do
    {:consumer, :the_state_does_not_matter}
  end

  def handle_events(events, _from, state) do
    IO.puts("received #{length(events)} events")
    {:noreply, [], state}
  end
end
