defmodule Abex.Schema.Experiment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Abex.Repo

  @statuses %{
    "0" => "created",
    "1" => "started",
    "2" => "stopped",
    "3" => "fullon"
  }

  @default_params [:tag, :status, :variants, :description,
                   :started_at, :stopped_at]

  schema "abex_experiments" do
    field :tag, :string
    field :status, :integer
    field :variants, :integer
    field :description, :string
    field :started_at, Ecto.DateTime
    field :stopped_at, Ecto.DateTime
    timestamps
  end

  @doc """
  Returns a Ecto.Changeset with validations
  """
  def changeset(experiment, params \\ %{}) do
    experiment
    |> cast(params, @default_params)
    |> unique_constraint(:id, name: :experiments_id_tag_index)
    |> validate_required([:tag, :description])
    |> validate_inclusion(:status, Map.keys(@statuses))
  end

  @doc """
  When raw data is nil it fetchs the experiment from
  database, when present returns it
  """
  def get(nil, key), do: get(key)
  def get(experiment_json, _key), do: experiment_json

  @doc """
  Returns experiment using experiment tag
  """
  def get(experiment_tag) when is_binary(experiment_tag) do
    Repo.get_by(__MODULE__, tag: experiment_tag)
  end

  @doc """
  Returns experiment using experiment id
  """
  def get(experiment_id) when is_number(experiment_id) do
    Repo.get(__MODULE__, experiment_id)
  end
end
