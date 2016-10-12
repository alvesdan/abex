defmodule Abex.APITest do
  use ExUnit.Case
  doctest Abex.API
  use ConnCase

  test "it creates a seed and sets a cookie with the key" do
    conn =
      fresh_conn
      |> Abex.API.seed

    cookies = fetch_conn_cookies(conn)
    assert cookies["abex_seed_key"]
  end

  test "it raises error when calling seed again" do
    conn =
      fresh_conn
      |> Abex.API.seed

    assert_raise Abex.API.AlreadySeedError,
      "can't call Abex.API.seed more than once per request", fn ->
      Abex.API.seed(conn)
    end
  end

  test "it sets the private attribute with seed" do
    conn =
      fresh_conn
      |> Abex.API.seed

    abex_seed_key = fetch_conn_cookies(conn)["abex_seed_key"]
    assert conn.private[:abex_seed].key == abex_seed_key
  end

  test "it stores seed in Redis when response is sent" do
    conn =
      fresh_conn
      |> Abex.API.seed
      |> Plug.Conn.send_resp(200, [])

    seed = Abex.Conn.get_seed(conn)
    assert Abex.Seed.retrieve(seed.key) == seed
  end

  test "when seed key exists, it retrieves seed from Redis" do
    seed = Abex.Seed.create
    Abex.Seed.store(seed)
    conn =
      fresh_conn
      |> put_req_cookie("abex_seed_key", seed.key)
      |> Abex.API.seed

    assert Abex.Conn.get_seed(conn) == seed
  end

  describe "Abex.API.track_experiment/2" do
    setup do
      create_test_experiments
    end

    test "it tracks experiment and returns conn", context do
      experiment = context[:two_variants_experiment]

      conn =
        fresh_conn
        |> Abex.API.track_experiment(experiment.tag)

      assert conn.private[:abex_experiments]
      tracked = conn.private[:abex_experiments][experiment.binary_id]

      assert tracked["variant"]
      assert tracked["tracked_at"]
    end
  end

  describe "Abex.API.get_variant/2" do
    setup do
      create_test_experiments
    end

    test "it returns experiment variant" do
      conn =
        fresh_conn
        |> Abex.API.track_experiment("two_variants_experiment")

      assert Abex.API.get_variant(conn, "two_variants_experiment")
    end

    test "when experiment is not tracked it returns nil" do
      refute Abex.API.get_variant(fresh_conn, "two_variants_experiment")
    end
  end
end
