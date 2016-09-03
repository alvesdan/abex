use Mix.Config

# Print only warnings and errors during test
config :logger, level: :warn

config :abex, :redis,
  host: "127.0.0.1",
  password: nil,
  size: 10,
  max_overflow: 5
