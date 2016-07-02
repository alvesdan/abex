defmodule Abex.DB do
  use Supervisor
  require Logger
  @redis_config Application.get_env(:abex, :redix)
  @variant_separator ":"
  @seed_separator ":"

	def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    pool_opts = [
      name: {:local, :abex_poolboy},
      worker_module: Redix,
      size: @redis_config[:size],
      max_overflow: @redis_config[:max_overflow],
    ]

    children = [
      :poolboy.child_spec(:abex_poolboy, pool_opts,
        Keyword.take(@redis_config, [:host, :password]))
    ]

    supervise(children, strategy: :one_for_one, name: __MODULE__)
  end

  def persist_experiment(user_seed, experiment_tag, variant) do
    add_experiment(user_seed, experiment_tag, variant)
    update_seed(user_seed, experiment_tag, variant)
  end

  def persist_goal(user_seed, goal) do
    update_seed(user_seed, goal)
  end

  def create_seed(user_seed, %{extend: extend}) do
    set_seed(user_seed, Poison.encode!(%{extend: extend, experiments: %{}}))
  end

  def current_seed(user_seed) do
    case get_seed(user_seed) do
      {:ok, nil} -> %{"experiments" => %{}}
      {:ok, seed} -> Poison.decode!(seed)
    end
  end

  def update_seed(user_seed, experiment_tag, variant) do
    updated =
      current_seed(user_seed)
      |> put_in(["experiments", experiment_tag], %{"variant" => variant, "stage" => [0]})
      |> Poison.encode!

    set_seed(user_seed, updated)
  end

  def update_seed(user_seed, goal) do
    merged =
      case Map.fetch(current_seed(user_seed), "goals") do
        {:ok, goals} -> Enum.uniq(goals ++ [goal])
        _ -> [goal]
      end

    updated =
      Map.put(current_seed(user_seed), "goals", merged)
      |> Poison.encode!

    set_experiments_goal(user_seed, goal)
    set_seed(user_seed, updated)
  end

  def count_variant(experiment_tag, variant) do
    key = ["experiment", experiment_tag, to_string(variant), "count"]
      |> Enum.join(@variant_separator)

    case command(["GET", key]) do
      {:ok, nil} -> 0
      {:ok, count} -> String.to_integer(count)
      _ -> nil
    end
  end

  def count_goal(experiment_tag, variant, goal) do
    key = ["experiment", experiment_tag, to_string(variant), goal, "count"]
      |> Enum.join(@variant_separator)

    case command(["GET", key]) do
      {:ok, nil} -> 0
      {:ok, count} -> String.to_integer(count)
      _ -> nil
    end
  end

  def flush! do
    if Mix.env == :prod, do: raise("Cannot flush Redis database in production!")
    command(["FLUSHDB"])
  end

  defp get_seed(user_seed) do
    key = "user_seed" <> @seed_separator <> user_seed
    command(["GET", key])
  end

  defp add_experiment(user_seed, experiment_tag, variant) do
    key = ["experiment", experiment_tag, to_string(variant)]
      |> Enum.join(@variant_separator)

    command(["SADD", key, user_seed])
    command(["INCR", key <> @variant_separator <> "count"])
  end

  defp set_seed(user_seed, value) do
    key = "user_seed" <> @seed_separator <> user_seed
    command(["SET", key, value])
  end

  defp set_experiments_goal(user_seed, goal) do
    current_seed(user_seed)
      |> Map.get("experiments", %{})
      |> Enum.each(fn({tag, content}) ->
        key = ["experiment", tag, to_string(content["variant"]), goal, "count"]
          |> Enum.join(@variant_separator)
        command(["INCR", key])
      end)
  end

	def command(command) do
    :poolboy.transaction(:abex_poolboy, &Redix.command(&1, command))
  end
end
