defmodule Abex.ExperimentConfig do
  @experiments_config Application.get_env(:abex, :experiments)

  def experiment_variants(experiment_tag) do
    case Map.fetch(@experiments_config[:active], experiment_tag) do
      {:ok, experiment} -> experiment.variants
      :error -> nil
    end
  end
end
