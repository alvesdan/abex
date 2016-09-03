defmodule Abex.ConnTest do
  use ExUnit.Case
  doctest Abex.Conn
  use ConnCase

  test "it gets current seed key cookie" do
    seed = Abex.Seed.create
    conn =
      fresh_conn
      |> put_req_cookie("abex_seed_key", seed.key)

    assert Abex.Conn.get_seed_key(conn) == seed.key
  end

  test "it sets the seed key cookie" do
    seed = Abex.Seed.create
    conn =
      fresh_conn
      |> Abex.Conn.set_seed_key(seed.key)

    assert fetch_conn_cookies(conn)["abex_seed_key"] == seed.key
  end

  test "it sets the seed private attribute" do
    seed = Abex.Seed.create
    conn =
      fresh_conn
      |> Abex.Conn.set_seed(seed)

    assert conn.private[:abex_seed] == seed
  end

  test "it retrieves the seed from connection" do
    seed = Abex.Seed.create
    conn =
      fresh_conn
      |> Abex.Conn.set_seed(seed)

    assert Abex.Conn.get_seed(conn) == seed
  end

  test "it registers a before send to the connection" do
    conn =
      fresh_conn
      |> Abex.Conn.set_before_send(&Sandbox.before_send_method/1)
      |> Plug.Conn.send_resp(200, [])

    assert conn.private[:before_send_sandbox]
  end
end
