use Mix.Config

import_config "#{Mix.env}.exs"
config :abex, ecto_repos: [Abex.Repo]
