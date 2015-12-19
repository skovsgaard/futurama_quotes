defmodule FuturamaQuotes.Server do
  use GenServer

  @mod __MODULE__

  defmodule Quote, do: defstruct by: nil, text: nil

  # Client

  def start_link, do: GenServer.start_link(@mod, :ok, name: @mod)
  def get_all, do: GenServer.call(@mod, :all)
  def get_by_id(id), do: GenServer.call(@mod, {:id, id})
  def get_random, do: GenServer.call(@mod, :random)
  def get_regex(regex), do: GenServer.call(@mod, {:regex, regex})

  # Callbacks

  def handle_call(:all, _from, state) do
    {:reply, quotes, state}
  end

  def handle_call({:id, id}, _from, state) do
    {:reply, quotes |> Enum.at(id |> String.to_integer), state}
  end

  def handle_call(:random, _from, state) do
    {:reply,
     quotes
     |> Enum.at(quotes |> Enum.count |> :random.uniform),
     state}
  end

  def handle_call({:regex, regex}, _from, state) do
    {:reply,
     quotes |> Enum.filter(&(&1.text |> String.match?(regex))),
     state}
  end

  # Private helpers
  defp build_quotes([h|t]) do
    cond do
      String.at(h,0) == "“" -> do_single_quote([h|t], [])
      String.match?(h, ~r/^[^" ,]+.+: /) -> do_multi_quote([h|t], [])
      true -> %Quote{text: Enum.join(t)}
    end
  end

  defp do_multi_quote([], acc), do: acc
  defp do_multi_quote([h|t], acc) do
    [character|text] = h |> String.split(":")
    do_multi_quote(t, [acc | %Quote{by: character, text: text |> Enum.join}])
  end

  defp do_single_quote([h|t], acc), do: :ok

  def quotes do
    "#{System.cwd!}/futurama.json"
      |> File.read!
      |> Poison.decode!
      |> Enum.map(&(&1 |> String.split("\n")))
      |> Enum.map(&build_quotes/1)
  end
end
    
