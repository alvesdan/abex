defmodule Abex.Mixfile do
  use Mix.Project

  def project do
    [app: :abex,
     version: "0.1.0",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     aliases: aliases()]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [mod: {Abex, []},
     applications: [:logger, :redix, :postgrex, :ecto,
                    :cowboy, :plug]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:plug, "~> 1.0"},
     {:poison, "~> 1.5"},
     {:redix, "~> 0.3"},
     {:poolboy, ">= 0.0.0"},
     {:postgrex, ">= 0.0.0"},
     {:ecto, "~> 2.0.0"},
     {:cowboy, "~> 1.0.0"},
     {:plug, "~> 1.0"}]
  end

  defp aliases do
    []
  end
end
