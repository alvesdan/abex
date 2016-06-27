# A/B.ex

A Plug A/B test framework aiming to be fast, reliable and scalable. This is a work in progress project.

## Installation

~~If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:~~ Currently only available to install from Github:

  1. Add `abex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:abex, git: "https://github.com/alvesdan/abex.git"}]
    end
    ```

  2. Ensure `abex` is started before your application:

    ```elixir
    def application do
      [applications: [:abex]]
    end
    ```

## Using with Phoenix

Create the experiments config: *(Currently this is only a placeholder to keep the config in some place. The idea is to move this to a proper DB storage with a web interface to create/edit experiments)*

```elixir
# Redis dependency
config :abex, :redix,
  host: "127.0.0.1",
  password: nil,
  size: 10,
  max_overflow: 5

config :abex, :experiments,
  active: %{
    "signup_button_color" => %{
      variants: 2
    },
  }
```
Create a new plug file to initialize the experiment seed:

```elixir
defmodule Finances.Plugs.Experiment do
  def init(default), do: default

  def call(conn, _) do
    conn |> Abex.Experiment.seed!
  end
end
```

Track the experiment on controller/view:

```eex
<%= if track_experiment!(@conn, "signup_button_color") == 0 do %>
<%# track_experiment!/2 will return one of the variants depending on config %>
  <p><a href="<%= user_path(@conn, :new) %>"
    class="btn btn-success btn-lg">Create your account now!</a></p>
<% else %>
  <p><a href="<%= user_path(@conn, :new) %>"
    class="btn btn-info btn-lg">Create your account now!</a></p>
<% end %>
```
