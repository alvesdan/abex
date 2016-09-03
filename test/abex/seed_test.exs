defmodule Abex.SeedTest do
  use ExUnit.Case
  doctest Abex.Seed

  setup do
    Abex.Redis.flush!
    :ok
  end

  test "it creates a seed" do
    seed = Abex.Seed.create
    assert seed.key
    assert seed.experiments == %{}
  end

  test "it creates uniq seed keys" do
    assert Abex.Seed.create != Abex.Seed.create
  end

  test "it stores seed data in Redis" do
    seed = Abex.Seed.create
    assert Abex.Seed.store(seed) == :ok
  end

  test "it retrieves seed data from Redis" do
    seed = Abex.Seed.create
    Abex.Seed.store(seed)
    assert Abex.Seed.retrieve(seed.key) == seed
  end

  test "when data is not present it returns nil" do
    assert Abex.Seed.retrieve("invalid") == nil
  end
end
