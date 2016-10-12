defmodule Abex.TrackerTest do
  use ExUnit.Case
  doctest Abex.Tracker
  use ConnCase

  setup do
    create_test_experiments
    {:ok, [two_variants_experiment: Abex.Experiment.retrieve("two_variants_experiment")]}
  end

  describe "Abex.Tracker.experiment_tracked?/2" do
    test "when experiment not tracked it returns false", context do
      experiment = context[:two_variants_experiment]
      assert Abex.Tracker.experiment_tracked?(experiment, fresh_conn) == {:not_tracked, experiment}
    end

    test "when experiment is tracked it returns true", context do
      experiment = context[:two_variants_experiment]
      conn =
        fresh_conn
        |> Plug.Conn.put_private(:abex_experiments, %{experiment.binary_id => 1})

      assert Abex.Tracker.experiment_tracked?(experiment, conn) == :tracked
    end
  end

  describe "Abex.Tracker.add_experiment/2" do
    test "it adds the experiment tracking data", context do
      experiment = context[:two_variants_experiment]
      conn =
        fresh_conn
        |> Abex.Tracker.add_experiment(experiment)

      assert conn.private[:abex_experiments][experiment.binary_id]["variant"]
      assert conn.private[:abex_experiments][experiment.binary_id]["tracked_at"]
    end

    test "it adds the tracked experiment id", context do
      experiment = context[:two_variants_experiment]
      conn =
        fresh_conn
        |> Abex.Tracker.add_experiment(experiment)

      assert conn.private[:abex_tracked_experiments] == [experiment.binary_id]
    end
  end
end
