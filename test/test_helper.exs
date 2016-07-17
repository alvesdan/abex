ExUnit.start()

Mix.Task.run "ecto.create", ["--quiet"]
Mix.Task.run "ecto.migrate", ["--quiet"]
Ecto.Adapters.SQL.Sandbox.mode(Abex.Repo, :manual)

defmodule TestSeedExtension do
  def call(_conn) do
    %{ id: 1, email: "example@email.com" }
  end
end

defmodule TestHelper do
  @started_at Ecto.DateTime.cast!("2090-10-10 00:00:00")
  alias Abex.Schema.Experiment
  use Plug.Test

  def create_test_experiments!(started_at \\ nil) do
    date = started_at || @started_at
    %Experiment{ tag: "test_experiment", started_at: date, variants: 2 }
      |> Abex.Repo.insert

    %Experiment{ tag: "three_variants_experiment",
      started_at: date, variants: 3 }
      |> Abex.Repo.insert
  end

  def get(path, opts) do
    conn = conn(:get, path)
    Abex.Router.call(conn, opts)
  end

  def post(path, params, opts) do
    conn = conn(:post, path, params)
      |> put_req_header("content-type", "text/html")
    Abex.Router.call(conn, opts)
  end
end
