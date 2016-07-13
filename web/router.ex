defmodule Abex.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/abex/experiments" do
    Abex.Controller.ExperimentController.call(conn)
  end
end
