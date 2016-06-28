defmodule Abex.ExperimentTest do
  use ExUnit.Case
  doctest Abex.Experiment
  alias Plug.Conn
  alias Abex.{Experiment, DB}

  setup do
    DB.delete_all!
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
  
  # Still have to fix this, failling some times
  test "it splits the users on variants" do
    Enum.reduce((1..90), [], fn(_n, tasks) ->
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

    experiments = Experiment.running_experiments(conn)

    assert experiments["test_experiment"]["goals"] == ["test_goal"]
    assert experiments["three_variants_experiment"]["goals"] == ["test_goal"]
  end
end
