defmodule FuturamaQuotes.Router do
  use Plug.Router
  alias FuturamaQuotes.Server

  plug :match
  plug :dispatch

  get "/quote", do: send_resp conn, 200, Server.get_all
  get "/quote/:id", do: send_resp conn, 200, "[quote from the list]"
  get "/quote/random", do: send_resp conn, 200, "[random quote]"
  get "/quote/regex/:regex", do: send_resp conn, 200, "[quote matching regex]"
  get "/quote/by/:person", do: send_resp conn, 200, "[quotes by person]"

  post "/quote", do: send_resp conn, 403, "[will add person]"
end
