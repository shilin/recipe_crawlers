defmodule RecipeCrawlers.SitemapHandler do
  @behaviour Saxy.Handler

  require Logger

  defmodule Url do
    defstruct loc: nil, lastmod: nil
  end

  defmodule State do
    defstruct current_tag: nil, current_item: %Url{}, buff: [], client: nil, demand: nil

    def set_current_tag(state, current_tag) do
      %State{state | current_tag: current_tag}
    end

    def append_item(state) do
      item = state.current_item
      buff = state.buff
      %State{state | buff: [item | buff]}
    end

    def update_current_item(state, field, content) do
      current_item = state.current_item
      %State{state | current_item: Map.put(current_item, field, content)}
    end
  end

  def start_link(stream) do
    client = self()
    Task.start(Saxy, :parse_stream, [stream, __MODULE__, %{client: client}])
  end

  def handle_event(:start_document, _prolog, state) do
    wait_for(state.client)
  end

  def handle_event(:start_element, {name, _attributes}, state) do
    {:ok, State.set_current_tag(state, name)}
  end

  def handle_event(:characters, content, state) do
    content = String.trim(content)
    case state.current_tag do
      field when content != "" and (field == "loc" or field == "lastmod") ->
        {:ok, State.update_current_item(state, String.to_existing_atom(field), content)}
      _ ->
        {:ok, state}
    end
  end

  def handle_event(:end_element, "url", state) do
    state = State.append_item(state)
    buff = state.buff
    if length(buff) < state.demand do
      {:ok, state};
    else
      client = state.client
      send(client, {:data, Enum.reverse(state.buff)})
      wait_for(client)
    end
  end

  def handle_event(:end_element, _, state) do
    {:ok, state}
  end

  def handle_event(:end_document, _, state) do
    send(state.client, {:data, Enum.reverse(state.buff)})
    {:ok, state}
  end

  def wait_for(client) do
    receive do
      {:more, demand} ->
        {:ok, %State{client: client, demand: demand}}
      {:stop, reason} ->
        {:stop, {:error, reason}}
      smth_else ->
        {:stop, {:unexpected_message, smth_else}}
    end
  end
end
