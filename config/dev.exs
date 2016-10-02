use Mix.Config

config :abex, :redis,
  host: "127.0.0.1",
  password: nil,
  size: 10,
  max_overflow: 5

config :abex, Abex.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "abex_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
