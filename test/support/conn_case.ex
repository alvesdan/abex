defmodule ConnCase do
  use ExUnit.CaseTemplate

  defmodule ConnCaseImport do
    alias Plug.Conn
    alias Plug.Conn.Unfetched
    use Plug.Test

    def fresh_conn do
      conn(:get, "/")
    end

    def fetch_conn_cookies(conn) do
      conn
      |> fetch_cookies
      |> Map.get(:cookies)
    end

    @started_at Ecto.DateTime.cast!("2016-01-01 00:00:00")
    def create_test_experiments(started_at \\ nil) do
      date = started_at || @started_at

      %Abex.Schema.Experiment{
        tag: "two_variants_experiment",
        started_at: date, variants: 2, status: 1, description: "Test"
      } |> Abex.Repo.insert

      %Abex.Schema.Experiment{
        tag: "three_variants_experiment",
        started_at: date, variants: 3, status: 1, description: "Test"
      } |> Abex.Repo.insert

      {:ok, [
        two_variants_experiment: Abex.Experiment.retrieve("two_variants_experiment"),
        three_variants_experiment: Abex.Experiment.retrieve("three_variants_experiment")
      ]}
    end
  end

  using do
    quote do
      use Plug.Test
      import ConnCaseImport
    end
  end

  setup tags do
    if tags[:async],
      do: :ok,
      else: :ok = Ecto.Adapters.SQL.Sandbox.checkout(Abex.Repo)
  end
end
