defmodule Abex.Controller.ExperimentControllerTest do
  use Abex.ConnCase
  use Plug.Test
  alias Abex.Schema.Experiment

  @opts Abex.Router.init([])

  test "it returns a list of existing experiments" do
    TestHelper.create_test_experiments!
    conn = get("/abex/experiments", @opts)
    assert conn.status == 200
    assert conn.resp_body =~ ~r/test_experiment/
    assert conn.resp_body =~ ~r/three_variants_experiment/
  end

  test "it renders the form to create a new experiment" do
    conn = get("/abex/experiments/new", @opts)
    assert conn.status == 200
    assert conn.resp_body =~ ~r/Experiment tag/
  end

  test "it creates new experiments" do
    params = %{
      experiment: %{
        tag: "test_experiment",
        variants: "2",
        started_at: "2018-10-10 15:00:00"
      }
    }

    conn = post("/abex/experiments", params, @opts)
    assert conn.status == 301
    assert Abex.Repo.get_by!(Experiment, %{tag: "test_experiment"})
  end

  test "with invalid params, render errors" do
    params = %{
      experiment: %{
        tag: "test_experiment"
      }
    }

    conn = post("/abex/experiments", params, @opts)
    assert conn.status == 422
    assert conn.resp_body =~ ~r/can\'t be blank/
  end
end
