# A/B.ex

A Plug A/B test framework aiming to be fast, reliable and scalable. This is a work in progress project and design changes are expected.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `abex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:abex, "~> 0.1.0"}]
    end
    ```

  2. Ensure `abex` is started before your application:

    ```elixir
    def application do
      [applications: [:abex]]
    end
    ```

