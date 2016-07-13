defmodule Abex.Schema.Experiment do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses %{
    0 => "created",
    1 => "started",
    2 => "stopped"
  }

  schema "experiments" do
    field :tag,        :string
    field :status,     :integer
    field :started_at, Ecto.DateTime
    field :variants,   :integer
  end

  def changeset(experiment, params \\ %{}) do
    experiment
    |> cast(params, [:tag, :status, :started_at, :variants])
    |> unique_constraint(:tag)
    |> validate_required([:tag, :started_at])
    |> validate_inclusion(:status, Map.keys(@statuses))
  end
end
