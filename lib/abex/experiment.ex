defmodule Abex.Experiment do
  alias Plug.Conn
  alias Plug.Conn.Unfetched
  alias Abex.DB

  def seed!(conn) do
    cookies = get_conn_cookies(conn)
    case Map.fetch(cookies, "user_seed") do
      {:ok, _user_seed} -> conn
      :error -> create_seed(conn)
    end
  end

  def get_variant(conn, experiment_tag) do
    experiments = conn |> running_experiments

    with {:ok, experiment} <- Map.fetch(experiments, experiment_tag),
         {:ok, variant} <- Map.fetch(experiment, "variant"),
         do: variant
  end

  def track_experiment!(conn, experiment_tag) do
    conn
      |> track_experiment(experiment_tag)
      |> running_experiments
      |> Map.fetch!(experiment_tag)
      |> Map.fetch!("variant")
  end

  def track_experiment(conn, experiment_tag)
    when is_binary(experiment_tag) do

    experiments = running_experiments(conn)
    user_seed = get_user_seed(conn)
    if !user_seed, do: raise("Ops, cannot track experiment without seed")
    conn |> put_experiment(user_seed, experiments, experiment_tag)
  end

  def track_goal(conn, goal) do
    user_seed = conn |> get_user_seed
    if !user_seed, do: raise("Ops, cannot track goal without seed")
    DB.persist_goal(user_seed, goal)
    conn
  end

  def get_user_seed(conn) do
    cookies = get_conn_cookies(conn)
    cookies["user_seed"]
  end

  def running_experiments(conn) do
    user_seed = conn |> get_user_seed
    if !user_seed, do: raise("Ops, cannot fetch experiments without seed")

    case DB.get(user_seed) do
      {:ok, nil} -> %{}
      {:ok, json_experiment} ->
        Poison.decode!(json_experiment)
    end
  end

  defp create_seed(conn) do
    timestamp = Tuple.to_list(:os.timestamp) |> Enum.map(&to_string/1)
    user_seed =
        :crypto.hash(:sha256, timestamp)
        |> Base.encode64

    DB.create_seed(user_seed)
    conn |> Plug.Conn.put_resp_cookie("user_seed", user_seed)
  end

  defp put_experiment(conn, user_seed, experiments, experiment_tag) do
    existing_variant =
      with {:ok, experiment} <- Map.fetch(experiments, experiment_tag),
           {:ok, variant} <- Map.fetch(experiment, "variant"),
           do: {:ok, variant}

    case existing_variant do
      {:ok, _variant} -> conn
      _ -> 
        variant = roll_dice(experiment_tag)
        DB.persist_experiment(user_seed, experiment_tag, variant)
        conn
    end
  end

  defp get_conn_cookies(conn) do
    case conn.cookies do
      %Unfetched{} -> Conn.fetch_cookies(conn).cookies
      cookies -> cookies
    end
  end

  defp roll_dice(experiment_tag) do
    variants = 
      Abex.ExperimentConfig.experiment_variants(experiment_tag)
     
    users = DB.count_variant(experiment_tag, 0)
    setup = %{users: users, variant: 0}

    %{users: _users, variant: variant} =
      (1..variants - 1) # Looping through all variants but 0
      |> Enum.reduce(setup, fn(current, setup) ->
        users_on_variant =
          DB.count_variant(experiment_tag, current)

        cond do
          setup[:users] > users_on_variant ->
            %{users: users_on_variant, variant: current}
          true -> setup
        end
      end)

    variant
  end
end
