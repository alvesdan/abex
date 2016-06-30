```elixir
# DB keys structure

"user_seed:$user_seed" => %{
	"experiments" => %{
		"$exp_tag" => { "variant" => $variant, "stages" => [0] },
	},
	"goals" => ["$goal:datetime", "$goal:datetime"],
	"stages => [0, 1]
}


"experiment:$exp_tag:$variant" => [
	"$user_seed:$datetime",
	"$user_seed:$datetime"
]
```
