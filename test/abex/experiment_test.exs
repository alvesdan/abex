defmodule Abex.ExperimentTest do
  use ExUnit.Case
  doctest Abex.Experiment
  alias Plug.Conn
  alias Abex.{Experiment, DB}

  setup do
    DB.flush!
    :ok
  end

  def fresh_conn do
    Plug.Adapters.Test.Conn.conn(%Conn{}, :get, "/abex", nil)
  end

	test "it creates an experiment seed" do
		user_seed =
      fresh_conn
      |> Experiment.seed!
      |> Experiment.get_user_seed

    assert user_seed
	end

  test "it does not change the seed if called again" do
		conn = fresh_conn |> Experiment.seed!
    user_seed = Experiment.get_user_seed(conn)

    updated =
      conn
      |> Experiment.seed!
      |> Experiment.get_user_seed
    
    assert updated == user_seed
  end
  
  test "when no cookie present, it creates the experiments cookie" do
    experiments =
      fresh_conn
      |> Experiment.seed!
      |> Experiment.track_experiment("test_experiment")
      |> Experiment.running_experiments

    assert experiments["test_experiment"]["variant"]
  end
  
  test "it splits the users on variants" do
    Enum.reduce(1..90, [], fn(_n, tasks) ->
      Process.sleep(1)
      tasks ++ [Task.async(fn ->
        fresh_conn
        |> Experiment.seed!
        |> Experiment.track_experiment("test_experiment")
        |> Experiment.track_experiment("three_variants_experiment")

      end)]
    end) |> Enum.map(&Task.await/1)

    test_experiment = Enum.map([0, 1], fn(n) -> DB.count_variant("test_experiment", n) end)
    three_variants_experiment = Enum.map([0, 1], fn(n) ->
      DB.count_variant("three_variants_experiment", n) end)

    assert Enum.uniq(test_experiment) == [45]
    assert Enum.uniq(three_variants_experiment) == [30]
  end

  test "with bang! it returns experiment variant" do
    variant =
      fresh_conn
      |> Experiment.seed!
      |> Experiment.track_experiment!("test_experiment")

    assert variant == 0
  end

  test "it returns variant" do
    conn =
      fresh_conn
      |> Experiment.seed!
      |> Experiment.track_experiment("test_experiment")

    assert Abex.Experiment.get_variant(conn, "test_experiment") == 0
  end

  test "it tracks goal for running experiments" do
    conn =
      fresh_conn
      |> Experiment.seed!
      |> Experiment.track_experiment("test_experiment")
      |> Experiment.track_experiment("three_variants_experiment")
      |> Experiment.track_goal("test_goal")

    seed = Experiment.get_user_seed(conn) |> DB.current_seed
    assert seed["goals"] == ["test_goal"]
  end

  test "it counts users on experiment/variant/goal" do
    fresh_conn
      |> Experiment.seed!
      |> Experiment.track_experiment("test_experiment")
      |> Experiment.track_experiment("three_variants_experiment")
      |> Experiment.track_goal("test_goal")

    assert DB.count_goal("test_experiment", 0, "test_goal") == 1
    assert DB.count_goal("three_variants_experiment", 0, "test_goal") == 1
  end

  test "it extends the user seed" do
    seed =
      fresh_conn
      |> Experiment.seed!(TestSeedExtension)
      |> Experiment.get_user_seed
      |> DB.current_seed

    assert seed["extend"]
    assert seed["extend"]["email"] == "example@email.com"
  end
end
