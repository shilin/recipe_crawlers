defmodule RecipeCrawlers.Consumer do
  use GenStage

  require Logger

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:consumer, :the_state_does_not_matter}
  end

  def handle_events(events, _from, state) do
    IO.puts("received #{length(events)} events")
    Enum.each(events, &recipe_page/1)
    {:noreply, [], state}
  end

  defp recipe_page(%{loc: loc}) do
    resp = HTTPoison.get!(loc)

    if resp.status_code == 200 do
      case Floki.parse_document(resp.body) do
        {:ok, page} ->
          description = Floki.find(page, "script[type=\"application/ld+json\"]")

          if Enum.empty?(description) do
            IO.puts("no description on page")
          else
            description
            |> List.first()
            |> Floki.children()
            |> Floki.text()
            |> Jason.decode!()
            |> IO.inspect()
          end

        _not_parced ->
          IO.puts("not parsed")
      end

      # {:ok, page} = Floki.parse_document(resp.body)
      # img =
      #   page
      #   |> Floki.find(page, ".g-print-visible > .recipe__print-cover > img")
      #   |> Floki.attribute("src")
    else
      Logger.error("Cannot download " <> loc)
    end
  end
end
