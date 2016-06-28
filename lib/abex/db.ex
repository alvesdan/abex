defmodule Abex.DB do
  use Supervisor
  require Logger
  @redis_config Application.get_env(:abex, :redix)

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
    key = experiment_tag <> "|" <> to_string(variant)
    add(key, user_seed)
    update_seed(user_seed, experiment_tag, variant)
  end

  def persist_goal(user_seed, goal) do
    update_seed(user_seed, goal)
  end

  def create_seed(user_seed) do
    set(user_seed, Poison.encode!(%{}))
  end

  def current_seed(user_seed) do
    case get(user_seed) do
      {:ok, nil} -> %{}
      {:ok, seed} -> Poison.decode!(seed)
    end
  end

  def update_seed(user_seed, experiment_tag, variant) do
    updated =
      current_seed(user_seed)
      |> Map.put(experiment_tag, %{"variant" => variant})
      |> Poison.encode!

    set(user_seed, updated)
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

    set(user_seed, updated)
  end

  def count_variant(experiment_tag, variant) do
    key = experiment_tag <> "|" <> to_string(variant)
    case command(["SCARD", key]) do
      {:ok, count} -> count
      _ -> nil
    end
  end

  def set(key, value) do
    command(["SET", key, value])
  end

  def get(key) do
    command(["GET", key])
  end

  def delete_all_and_warn! do
    Logger.warn "Flusing Redis database!"
    delete_all!
  end

  def delete_all! do
    command(["FLUSHDB"])
  end

  defp add(key, value) do
    command(["SADD", key, value])
  end

	defp command(command) do
    :poolboy.transaction(:abex_poolboy, &Redix.command(&1, command))
  end
end
