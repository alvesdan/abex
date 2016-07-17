defmodule Abex.Router do
  use Plug.Router
  alias Abex.Controller.ExperimentController

	plug Plug.Static,
		at: "/public",
		from: :abex,
		only: ~w(css)

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart],
    pass: ["text/*"]

  plug :match
  plug :dispatch


  get "/abex/experiments", do: ExperimentController.index(conn)
  get "/abex/experiments/new", do: ExperimentController.new(conn)
  post "/abex/experiments",
    do: ExperimentController.create(conn, conn.params)
end
