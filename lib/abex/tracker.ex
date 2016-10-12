defmodule Abex.Tracker do
  alias Abex.{Conn, Experiment}

  @experiments_key :abex_experiments
  @tracked_experiments_key :abex_tracked_experiments

  @spec experiment_tracked?(Experiment.t, Conn.t) :: :tracked | {:not_tracked, Experiment.t}
  def experiment_tracked?(experiment, conn) do
    if get_in(conn.private, [@experiments_key, experiment.id]),
      do: :tracked,
      else: {:not_tracked, experiment}
  end

  @doc """
  Adds experiment data to connection object.

  Here we add the information needed to keep track of experiment
  variant and time
  """
  @spec add_experiment(Conn.t, Experiment.t) :: Conn.t
  def add_experiment(conn, experiment) do
    conn
    |> add_experiment_tracking_data(experiment)
    |> add_tracked_experiment(experiment)
  end

  defp add_experiment_tracking_data(conn, experiment) do
    experiments =
      conn
      |> Conn.get_experiments
      |> Map.put_new(experiment.id,
        %{
          variant: Enum.random(experiment.variants),
          tracked_at: unix_time
        })

    Plug.Conn.put_private(conn, @experiments_key, experiments)
  end

  # We need to keep track of experiments tracked within the request
  # in order to calculate variant participants
  defp add_tracked_experiment(conn, experiment) do
    experiments =
      Map.get(conn.private, @tracked_experiments_key, [])
      |> Enum.concat([experiment.id])
      |> Enum.uniq

    Plug.Conn.put_private(conn, @tracked_experiments_key, experiments)
  end

  defp unix_time, do: DateTime.to_unix(DateTime.utc_now)
end
