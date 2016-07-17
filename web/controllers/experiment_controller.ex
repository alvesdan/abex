defmodule Abex.Controller.ExperimentController do
  alias Abex.Schema.Experiment
  alias Abex.Repo
  import Plug.Conn

  def index(conn) do
    experiments = Repo.all(Experiment)
    conn
      |> Abex.View.render(
        "experiments/index.html.eex", [experiments: experiments])
  end

  def new(conn) do
    experiment = %Experiment{}
    conn
      |> Abex.View.render(
        "experiments/new.html.eex", [experiment: experiment, errors: nil])
  end

  def create(conn, nil) do
    create(conn, %{"experiment" => %{}})
  end

  def create(conn, %{"experiment" => experiment_params}) do
    changeset = Experiment.changeset(%Experiment{}, experiment_params)
    case Repo.insert(changeset) do
      {:ok, experiment} ->
        conn
        |> put_resp_header("location", "/abex/experiments")
        |> resp(301, "You are being redirected")
        |> halt
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> Abex.View.render("experiments/new.html.eex",
          [experiment: changeset.data, errors: changeset.errors])
    end
  end
end
