defmodule Abex.ExperimentTest do
  use ExUnit.Case
  use ConnCase
  doctest Abex.Experiment
  alias Abex.Experiment

  setup do
    Abex.Redis.flush!
    create_test_experiments
  end

  test "it retrieves experiment" do
    experiment = Experiment.retrieve("two_variants_experiment")

    assert experiment.tag == "two_variants_experiment"
    assert experiment.variants == [0, 1]
  end

  test "it saves the experiment on cache after retrieving" do
    experiment = Experiment.retrieve("two_variants_experiment")

    cached =
      Abex.Cache.get(experiment.id)
      |> Poison.decode!(as: %Abex.Experiment{})

    assert cached == experiment
  end

  test "it loads from database and cache" do
    experiment = Experiment.retrieve("two_variants_experiment")

    assert experiment == Experiment.retrieve(experiment.id)
  end
end
