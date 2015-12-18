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
  def build_quotes(q_list) do
    for entry <- q_list do
      if String.contains?(entry, " -")
      or String.contains?(entry, "--")
      or String.starts_with?(entry, "“")do
        [h|t] =
          entry
          |> String.replace("\n", "")
          |> String.split("-")
          |> Enum.reverse
        
        %Quote{
          by: h |> String.replace(~r/,.*/, "", global: true),
          text: t |> Enum.reverse |> Enum.slice(1, Enum.count(t)) |> Enum.join
        }
      else
        if String.contains?(entry, ":") do
          [h|t] = entry |> String.split(~r/: /)
          %Quote{by: h, text: Enum.join(t)}
        else
          %Quote{by: nil, text: entry}
        end
      end
    end
  end


  defp quotes do
    "#{System.cwd!}/futurama.json"
      |> File.read!
      |> Poison.decode!
      |> build_quotes
  end
end
    
