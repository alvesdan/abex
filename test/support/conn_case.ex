defmodule Abex.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Abex.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]
    end
  end

  setup tags do
    if tags[:async],
      do: :ok,
      else: :ok = Ecto.Adapters.SQL.Sandbox.checkout(Abex.Repo)
  end
end
