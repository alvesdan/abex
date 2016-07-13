defmodule Abex.Schema.ExperimentTest do
  use Abex.ModelCase
  doctest Abex.Schema.Experiment
  alias Abex.Schema.Experiment
  alias Abex.Repo

  @started_at Ecto.DateTime.cast!("2016-10-10 00:00:00")
  @valid_params %{tag: "test_experiment", started_at: @started_at}

  test "it validates tag uniquesess" do
    Map.merge(%Experiment{}, @valid_params) |> Repo.insert

    changeset = Experiment.changeset(
      %Experiment{}, @valid_params)

    {:error, changeset} = Repo.insert(changeset)
    assert changeset.errors[:tag]
  end
end
