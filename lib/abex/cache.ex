defmodule Abex.Cache do
  alias Abex.Redis
  @cache_prefix "abex_cache:"

  def get(key) do
    Redis.get(@cache_prefix <> to_string(key))
  end

  def set(keys, value) when is_list(keys) do
    Enum.map(keys, &set(&1, value))
  end

  def set(nil, _value), do: raise("Cannot save cache without key")
  def set(key, value) do
    Redis.set(@cache_prefix <> to_string(key), value)
  end
end
