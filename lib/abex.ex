defmodule Abex do
  use Application
  alias Abex.Router

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Extranslate.Worker, [arg1, arg2, arg3]),
      supervisor(Abex.Repo, []),
      supervisor(Abex.DB, []),
      Plug.Adapters.Cowboy.child_spec(:http, Router, [], [port: 4001])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Abex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
