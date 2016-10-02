defmodule Abex.Schema.ExperimentTest do
  use ExUnit.Case
  doctest Abex.Schema.Experiment
  use ConnCase
  alias Abex.Schema.Experiment

  setup do
    create_test_experiments
  end

  test "it loads experiment with tag" do
    experiment = Experiment.get("two_variants_experiment")
    assert experiment.id
  end

  test "it loads experiment with id" do
    experiment = Experiment.get("two_variants_experiment")
    assert Experiment.get(experiment.id) == experiment
  end
end
