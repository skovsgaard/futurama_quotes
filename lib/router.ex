defmodule FuturamaQuotes.Router do
  use Plug.Router
  alias FuturamaQuotes.Server
  alias Poison.encode!

  plug :match
  plug :dispatch

  get "/",
    do: send_resp conn, 200, Server.get_all |> encode!
  get "/quote",
    do: send_resp conn, 200, Server.get_all |> encode!
  get "/quote/:id",
    do: send_resp conn, 200, Server.get_by_id(id) |> encode!
  get "/quote/random",
    do: send_resp conn, 200, Server.get_random |> encode!
  get "/quote/regex/:regex",
    do: send_resp conn, 200, Server.get_regex(regex) |> encode!
  get "/quote/by/:person",
    do: send_resp conn, 200, Server.get_by_person(person) |> encode!

  post "/quote", do: send_resp conn, 403, "[will add person]"

  match _, do: send_resp conn, 404, "No quote found for that route"
end
