defmodule Sandbox do
  def before_send_method(conn) do
    Plug.Conn.put_private(conn, :before_send_sandbox, true)
  end
end
