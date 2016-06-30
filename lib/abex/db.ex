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
    set_seed(user_seed, Poison.encode!(%{extend: extend}))
  end

  def current_seed(user_seed) do
    case get_seed(user_seed) do
      {:ok, nil} -> %{}
      {:ok, seed} -> Poison.decode!(seed)
    end
  end

  def update_seed(user_seed, experiment_tag, variant) do
    updated =
      current_seed(user_seed)
      |> Map.put(experiment_tag, %{"variant" => variant})
      |> Poison.encode!

    set_seed(user_seed, updated)
  end

  def update_seed(user_seed, goal) do
    updated =
      current_seed(user_seed)
      |> Enum.reduce(%{}, fn({key, value}, acc) ->
        goals =
          case Map.fetch(value, "goals") do
            {:ok, goals} -> Enum.uniq(goals ++ [goal])
            _ -> [goal]
          end

        Map.put(acc, key, Map.put(value, "goals", goals))
      end)
      |> Poison.encode!

    set_seed(user_seed, updated)
  end

  def count_variant(experiment_tag, variant) do
    key = ["experiment", experiment_tag, to_string(variant), "count"]
      |> Enum.join(@variant_separator)

    case command(["GET", key]) do
      {:ok, nil} -> 1
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

	def command(command) do
    :poolboy.transaction(:abex_poolboy, &Redix.command(&1, command))
  end
end
