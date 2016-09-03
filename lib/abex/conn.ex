defmodule Abex.Conn do
  @moduledoc """
  Wrapper to manipulate Plug.Conn objects
  """
  import Plug.Conn, only: [
    fetch_cookies: 1,
    put_resp_cookie: 3,
    put_private: 3,
    register_before_send: 2
  ]

  @abex_seed_key "abex_seed_key"

  alias Plug.Conn

  @doc """
  Returns the seed key for a connection if present
  """
  @spec get_seed_key(Conn.t) :: String.t | nil
  def get_seed_key(conn) do
    conn
    |> fetch_cookies
    |> Map.get(:cookies)
    |> Map.get(@abex_seed_key)
  end

  @doc """
  Sets the seed key cookie for a connection
  """
  @spec set_seed_key(Conn.t, String.t) :: Conn.t
  def set_seed_key(conn, seed_key) do
    put_resp_cookie(conn, @abex_seed_key, seed_key)
  end

  @doc """
  Sets the private attribute with seed data
  """
  @spec set_seed(Conn.t, Abex.Seed.t) :: Conn.t
  def set_seed(conn, seed) do
    put_private(conn, :abex_seed, seed)
  end

  @spec get_seed(Conn.t) :: Conn.t
  def get_seed(conn) do
    conn.private[:abex_seed]
  end

  @doc """
  Registers a before send to the connection that
  persists the seed data in Redis
  """
  @spec set_before_send(Conn.t) :: Conn.t
  def set_before_send(conn) do
    register_before_send(conn, fn(conn) ->
      conn |> get_seed |> Abex.Seed.store
      conn
    end)
  end

  def set_before_send(conn, callback) do
    register_before_send(conn, callback)
  end
end
