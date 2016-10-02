defmodule Abex.Repo.Migrations.CreateTableAbexExperiments do
  use Ecto.Migration

  def change do
    create table(:abex_experiments) do
      add :tag, :string
      add :status, :integer, default: 0
      add :variants, :integer, default: 2
      add :description, :text
      add :started_at, :datetime
      add :stopped_at, :datetime
      timestamps
    end

    create unique_index(:abex_experiments, [:id, :tag], name: :experiments_id_tag_index)
  end
end
