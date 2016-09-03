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
  end

  using do
    quote do
      use Plug.Test
      import ConnCaseImport
    end
  end
end
