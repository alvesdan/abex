defmodule Abex.Redis do
  require Logger
  use Supervisor
  @redis_config Application.get_env(:abex, :redis)

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

  def set(key, value) do
    case command(["SET", key, value]) do
      {:ok, "OK"} -> :ok
      {:error, _error} ->
        Logger.warn("Failed to store Redis key #{key}")
        :error
    end
  end

  def get(key) do
    case command(["GET", key]) do
      {:ok, value} -> value
      {:error, _error} -> nil
    end
  end

  def flush! do
    if Mix.env == :prod, do: raise("Cannot flush Redis database in production!")
    command(["FLUSHDB"])
  end

  def command(command) do
    :poolboy.transaction(:abex_poolboy, &Redix.command(&1, command))
  end
end
