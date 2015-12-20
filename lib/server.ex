defmodule FuturamaQuotes.Server do
  use GenServer
  require Logger

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
    Logger.info "GET /quote"
    {:reply, state ++ quotes, state}
  end

  def handle_call({:id, id}, _from, state) do
    Logger.info "GET /quote/id/#{id}"
    {:reply,
     [state|quotes]
     |> List.flatten
     |> Enum.at(id |> String.to_integer),
     state}
  end

  def handle_call(:random, _from, state) do
    Logger.info "GET /quote/random"
    {:reply,
     state
     |> List.flatten(quotes)
     |> Enum.at(quotes |> Enum.count |> :random.uniform),
     state}
  end

  def handle_call({:regex, regex_text}, _from, state) do
    {:ok, regex} = Regex.compile(regex_text)
    Logger.info "GET /quote/regex/#{Macro.to_string(regex)}"
    {:reply,
     state
     |> List.flatten(quotes)
     |> Enum.filter(&(&1 |> String.match?(regex))),
     state}
  end

  def handle_call({:store, conn_state}, _from, state) do
    {:ok, _body, q} = conn_state
    Logger.info "POST /quote \"#{q.body_params["quote"]}\""
    {:reply,
      q.body_params["quote"],
      state ++ [q.body_params["quote"]]}
  end

  # Private helpers
  defp quotes do
    "#{System.cwd!}/futurama.json"
    |> File.read!
    |> Poison.decode!
  end
end
    
