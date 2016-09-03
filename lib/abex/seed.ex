defmodule Abex.Seed do
  @derive [Poison.Encoder]
  defstruct [:key, :experiments]

  @type key :: String.t
  @type experiments :: %{ binary => any }
  @type t :: %__MODULE__{ key: key, experiments: experiments }

  def create, do: create(UUID.uuid1)
  def create(key) do
    %__MODULE__{
      key: key ,
      experiments: %{}
    }
  end

  @spec store(t) :: :ok | :error
  def store(%__MODULE__{} = seed) do
    Abex.Redis.set(seed.key, Poison.encode!(seed))
  end

  @spec retrieve(key) :: t | nil
  def retrieve(seed_key) do
    case Abex.Redis.get(seed_key) do
      nil -> nil
      seed_json -> Poison.decode!(seed_json, as: %__MODULE__{})
    end
  end
end
