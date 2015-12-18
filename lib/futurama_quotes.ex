defmodule FuturamaQuotes do
  use Application
  alias FuturamaQuotes.Router

  def start(_type, _args) do
    {:ok, _} = Plug.Adapters.Cowboy.http Router, []
    import Supervisor.Spec, warn: false

    children = [
      worker(FuturamaQuotes.Server, [], id: FuturamaQuotes.Server)
    ]

    opts = [strategy: :one_for_one, name: FuturamaQuotes.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
