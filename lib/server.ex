defmodule FuturamaQuotes.Server do
  use GenServer

  @mod __MODULE__

  defmodule Quote do
    defstruct by: nil, text: nil
  end

  # Client

  def start_link, do: GenServer.start_link(@mod, :ok, name: @mod)
  def get_all!, do: GenServer.call(@mod, :all)
  def get_by_id!(id), do: GenServer.call(@mod, {:id, id})
  def get_random, do: GenServer.call(@mod, :random)
  def get_regex(regex), do: GenServer.call(@mod, {:regex, regex})

  # Callbacks

  def handle_call(:all, _from, state) do
    {:reply, quotes, state}
  end

  def handle_call({:id, id}, _from, state) do
    {:reply,
     quotes |> Enum.filter(&(&1.by == id)),
     state}
  end

  def handle_call(:random, _from, state) do
    {:reply,
     quotes
     |> Enum.at(quotes
                |> Enum.count
                |> :random.uniform),
     state}
  end

  def handle_call({:regex, regex}, _from, state) do
    {:reply,
     quotes |> Enum.filter(&(&1.text |> String.match?(regex))),
     state}
  end

  # Private helpers
  defp build_quotes(q_list) do
    for entry <- q_list do
      entry
      |> String.split("\n")
      |> build_entry
    end
  end

  defp build_entry(entry) do
    cond do
      String.match?(List.first(entry), ~r/^[^ ]*: /) ->
        [h|t] = entry |> List.first |> String.split(": ")
        %Quote{by: h, text: t |> Enum.join}
      String.match?(List.first(entry), ~r/^“/) ->
        %Quote{by: entry |> List.last |> String.split(" -") |> List.last,
               text: entry}
      true -> %Quote{text: Enum.join(entry)}
    end
  end

  def quotes do
    "#{System.cwd!}/futurama.json"
      |> File.read!
      |> Poison.decode!
      |> build_quotes
  end
end
    
