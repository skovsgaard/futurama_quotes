defmodule FuturamaQuotes.Server do
  use GenServer

  @mod __MODULE__

  defmodule Quote, do: defstruct by: "", text: nil

  # Client

  def start_link, do: GenServer.start_link(@mod, :ok, name: @mod)
  def get_all, do: GenServer.call(@mod, :all)
  def get_by_id(id), do: GenServer.call(@mod, {:id, id})
  def get_random, do: GenServer.call(@mod, :random)
  def get_regex(regex), do: GenServer.call(@mod, {:regex, regex})
  def get_by_person(person), do: GenServer.call(@mod, {:person, person})

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

  def handle_call({:person, person}, _from, state) do
    {:reply,
     quotes |> Enum.filter(&(&1.by |> String.contains?(person))),
     state}
  end

  # Private helpers
  defp take_multi(q_list) do
    q_list
    |> Enum.filter(&(&1 |> String.match?(~r/^[ “,]+.+: /)))
    |> Enum.map(fn q ->
      pair = q |> String.split(":")
      %Quote{
        by: hd(pair),
        text: pair |> Enum.slice(1..-1) |> Enum.join
      }
    end)
  end

  defp take_dashed(q_list) do
    q_list
    |> Enum.filter(&(&1 |> String.at(0) == "“"))
    |> Enum.map(fn q ->
      pair = q |> String.split(~r/\s-/)
      %Quote{
        by: pair |> List.last |> String.replace("-",""),
        text: pair |> Enum.slice(0..-2) |> Enum.join
      }
    end)
  end

  defp take_unattributed(q_list) do
    q_list
    |> Enum.filter(fn q ->
      not String.match?(q, ~r/^[ “,]+.+: /) and String.at(q,0) != "“"
    end)
    |> Enum.map(&(%Quote{text: &1}))
  end

  defp quotes do
    {:ok, document} =
      "#{System.cwd!}/futurama.json"
      |> File.read!
      |> Poison.decode
    take_multi(document) ++
    take_dashed(document) ++
    take_unattributed(document)
  end
end
    
