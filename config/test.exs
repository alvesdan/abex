use Mix.Config

config :abex, :redix,
  host: "127.0.0.1",
  password: nil,
  size: 10,
  max_overflow: 5

config :abex, :experiments,
  active: %{
    "test_experiment" => %{
      variants: 2
    },
    "three_variants_experiment" => %{
      variants: 3
    }
  }
