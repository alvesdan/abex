defmodule Abex.Repo.Migrations.CreateExperiments do
  use Ecto.Migration

  def change do
    create table(:experiments) do
      add :tag, :string
      add :status, :integer, default: 0
      add :started_at, :datetime
      add :variants, :integer, default: 2
    end

    create unique_index(:experiments, [:tag])
  end
end
