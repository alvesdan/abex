defmodule Abex.API do
  alias Abex.Conn

  defmodule AlreadySeedError do
    defexception message: "can't call Abex.API.seed more than once per request"
  end

  @spec seed(Conn.t) :: Conn.t
  def seed(conn) do
    seed =
      case Conn.get_seed_key(conn) do
        nil -> Abex.Seed.create
        seed_key ->
          Abex.Seed.retrieve(seed_key) || Abex.Seed.create(seed_key)
      end

    if Conn.get_seed(conn), do: raise(AlreadySeedError)

    conn
    |> Conn.set_seed_key(seed.key)
    |> Conn.set_seed(seed)
    |> Conn.load_experiments_from_seed(seed)
    |> Conn.set_before_send
  end

  @spec track_experiment(Conn.t, binary) :: Conn.t
  def track_experiment(conn, experiment_tag) do
    Abex.Experiment.retrieve(experiment_tag)
    |> Abex.Tracker.experiment_tracked?(conn)
    |> case do
      :tracked -> conn
      {:not_tracked, experiment} ->
        Abex.Tracker.add_experiment(conn, experiment)
    end
  end

  @spec get_variant(Conn.t, binary) :: integer | nil
  def get_variant(conn, experiment_tag) do
    experiment = Abex.Experiment.retrieve(experiment_tag)
    get_in(conn.private, [:abex_experiments, experiment.id, :variant])
  end
end
