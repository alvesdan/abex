defmodule Abex.Controller.ExperimentController do
  import Plug.Conn
  require EEx

  def call(conn) do
    conn |> send_resp(200, "Hello world!")
  end
end
