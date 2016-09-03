defmodule Abex.API do
  alias Abex.Conn

  defmodule AlreadySeedError do
    defexception message: "can't call Abex.API.seed more than once per request"
  end

  @spec seed(Conn.t) :: Conn.t
  def seed(conn) do
    seed =
      case Conn.get_seed_key(conn) do
        nil -> Abex.Seed.create
        seed_key ->
          Abex.Seed.retrieve(seed_key) || Abex.Seed.create(seed_key)
      end

    if Conn.get_seed(conn), do: raise(AlreadySeedError)

    conn
    |> Conn.set_seed_key(seed.key)
    |> Conn.set_seed(seed)
    |> Conn.set_before_send
  end
end
