ExUnit.start()

defmodule TestSeedExtension do
  def call(_conn) do
    %{ id: 1, email: "example@email.com" }
  end
end
