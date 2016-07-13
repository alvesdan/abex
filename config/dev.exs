use Mix.Config

config :abex, :redix,
  host: "127.0.0.1",
  password: nil,
  size: 10,
  max_overflow: 5

config :abex, Abex.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "abex_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
