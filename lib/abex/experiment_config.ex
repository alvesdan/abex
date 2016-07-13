defmodule Abex.ExperimentConfig do
  alias Abex.Repo
  alias Abex.Schema.Experiment

  def experiment_variants(experiment_tag) do
    case Repo.get_by(Experiment, tag: experiment_tag) do
      nil -> nil
      experiment -> experiment.variants
    end
  end
end
