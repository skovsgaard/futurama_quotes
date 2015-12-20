defmodule FuturamaQuotes.Server do
  use GenServer

  @mod __MODULE__

  defmodule Quote, do: defstruct character: "", text: nil

  # Client

  def start_link, do: GenServer.start_link(@mod, [], name: @mod)
  def get_all, do: GenServer.call(@mod, :all)
  def get_by_id(id), do: GenServer.call(@mod, {:id, id})
  def get_random, do: GenServer.call(@mod, :random)
  def get_regex(regex), do: GenServer.call(@mod, {:regex, regex})
  def get_by_person(person), do: GenServer.call(@mod, {:person, person})
  def store_quote(conn), do: GenServer.call(@mod, {:store, conn})

  # Callbacks

  def handle_call(:all, _from, state) do
    {:reply, state ++ quotes, state}
  end

  def handle_call({:id, id}, _from, state) do
    {:reply,
     List.flatten(state, quotes
                         |> Enum.at(id |> String.to_integer)),
     state}
  end

  def handle_call(:random, _from, state) do
    {:reply,
     state
     |> List.flatten(quotes)
     |> Enum.at(quotes |> Enum.count |> :random.uniform),
     state}
  end

  def handle_call({:regex, regex}, _from, state) do
    {:reply,
     state
     |> List.flatten(quotes)
     |> Enum.filter(&(&1.text |> String.match?(regex))),
     state}
  end

  def handle_call({:person, person}, _from, state) do
    {:reply,
     state
     |> List.flatten(quotes)
     |> Enum.filter(&(&1.character
                      |> String.downcase
                      |> String.contains?(person |> String.downcase))),
     state}
  end

  def handle_call({:store, conn_state}, _from, state) do
    {:ok, _body, q} = conn_state
    storable = %Quote{character: q.body_params["character"],
                      text: q.body_params["text"]}
    {:reply,
      storable,
      state ++ [storable]}
  end

  # Private helpers
  defp take_multi(q_list) do
    q_list
    |> Enum.filter(&(&1 |> String.match?(~r/^[^ ]+.+: /)))
    |> Enum.map(fn q ->
      pair = q |> String.split(":")
      %Quote{
        character: hd(pair),
        text: pair |> Enum.slice(1..-1) |> Enum.join
      }
    end)
  end

  defp take_dashed(q_list) do
    q_list
    |> Enum.filter(&(&1 |> String.at(0) == "“"))
    |> Enum.map(fn q ->
      full_block = String.split(q, ~r/\s-/)
      names = full_block |> Enum.slice(1..-1) |> Enum.take_every(2) 
      texts = Enum.take_every(full_block, 2)
      
      for {name, text} <- Enum.zip(names, texts) do
        %Quote{
          character: name,
          text: text
        }
      end
    end)
    |> List.flatten
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
    
