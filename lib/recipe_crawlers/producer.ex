defmodule RecipeCrawlers.Producer do
  use GenStage

  def start_link(sitemap_path) do
    GenStage.start_link(__MODULE__, sitemap_path, name: __MODULE__)
  end

  def init(sitemap_path) do
    stream = File.stream!(sitemap_path, [:trim_bom])
    {:ok, parser} = RecipeCrawlers.SitemapHandler.start_link(stream)
    Process.monitor(parser)
    send(parser, {:more, 100})
    {:producer, parser}
  end

  def handle_info({:data, events}, parser) do
    Process.send_after(parser, {:more, 100}, 1000)
    {:noreply, events, parser}
  end

  def handle_info({:DOWN, _ref, :process, pid, :normal}, state) when state == pid,
    do: {:stop, :normal, state}

  def handle_demand(demand, parser) do
    IO.puts("Demand #{demand} events")
    {:noreply, [], parser}
  end
end
