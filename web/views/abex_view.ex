defmodule Abex.View do
  import Plug.Conn
  require EEx

  def render(conn, template, assigns) do
    templ = render_template(template, assigns)
    layout = EEx.eval_file(
      "web/templates/layout.html.eex",
      [template: templ] ++ assigns
    )
    conn |> send_resp(conn.status || 200, layout)
  end

  def url_for(path) do
    "/" <> path
  end

  def render_template(template, assigns) do
    path = "web/templates/" <> template
    EEx.eval_file(path, assigns)
  end

  def parse_error_message(message) do
    case message do
      {error, bindings} ->
        bindings |> Enum.reduce(error, fn({tag, value}, acc) ->
          String.replace(acc, to_string(tag), to_string(value))
        end)
      error -> error
    end
  end
end
