defmodule FuturamaQuotes.Storage do
  @mod __MODULE__

  def start_link, do: Agent.start_link(fn -> quotes end, name: @mod)
  def fetch_all, do: Agent.get(@mod, &(&1))
  def save_quote(line),
    do: Agent.update(@mod, fn quotes -> [line|quotes] end)

  defp quotes do
    "#{System.cwd!}/futurama.json"
    |> File.read!
    |> Poison.decode!
  end
end
