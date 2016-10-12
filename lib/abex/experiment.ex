defmodule Abex.Experiment do
  require Logger
  @derive [Poison.Encoder]
  defstruct [
    id: nil,
    binary_id: nil,
    tag: nil,
    variants: [0, 1],
    status: :created
  ]

  @type t :: %__MODULE__{
    id: integer,
    binary_id: binary,
    tag: binary,
    variants: list,
    status: atom
  }

  @doc """
  Loads experiment from cache or database
  """
  @spec retrieve(binary | integer) :: t
  def retrieve(key) do
    key |> Abex.Cache.get |> transform(key)
  end

  @doc """
  Stores the experiment data in cache
  """
  @spec store(t) :: t | :error
  def store(%__MODULE__{id: id, tag: tag} = experiment) do
    stored = Abex.Cache.set([id, tag], Poison.encode!(experiment))
    case stored do
      [:ok, :ok] -> experiment
      _ ->
        # We don't want to crash the application if we fail to
        # save the experiment in cache but we need to inform
        # the user that this is happening
        """
        WARN! Failed to save experiment #{id}/#{tag} in cache. Please
        check logs for more details.
        """
        |> Logger.warn
        experiment
    end
  end

  defp transform(nil, key) do
    Abex.Schema.Experiment.get(key)
    |> transform
    |> store
  end

  defp transform(json, _key) when is_binary(json) do
    json
    |> Poison.decode!(as: %__MODULE__{})
  end

  defp transform(data) when is_map(data) do
    %__MODULE__{
      id: data.id,
      binary_id: to_string(data.id),
      tag: data.tag,
      variants: variants(data.variants),
      status: data.status
    }
  end

  defp variants(number),
    do: 0..(number - 1) |> Enum.to_list
end
