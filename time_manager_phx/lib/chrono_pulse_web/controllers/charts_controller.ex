defmodule ChronoPulseWeb.ChartsController do
  use ChronoPulseWeb, :controller

  alias ChronoPulse.TimeTracking

  plug :accepts, ["json"]

  # GET /api/charts/hours
  def total_hours(conn, _params) do
    rows = TimeTracking.list_workingtimes()
    |> Enum.group_by(fn w -> Date.to_iso8601(DateTime.to_date(w.start)) end)
    |> Enum.map(fn {date, list} ->
      seconds = Enum.reduce(list, 0, fn w, acc -> acc + diff_seconds(w.start, w.end) end)
      minutes = div(seconds, 60)
      %{date: date, seconds: seconds, minutes: minutes, hours: Float.round(minutes / 60, 2)}
    end)
    render(conn, :hours, rows: rows)
  end

  # GET /api/charts/user/:user_id/hours
  def user_hours(conn, %{"user_id" => user_id} = params) do
    case Map.get(params, "date") do
      nil ->
        rows = TimeTracking.list_workingtimes()
        |> Enum.filter(&(&1.user_id == user_id))
        |> Enum.group_by(fn w -> Date.to_iso8601(DateTime.to_date(w.start)) end)
        |> Enum.map(fn {date, list} ->
          seconds = Enum.reduce(list, 0, fn w, acc -> acc + diff_seconds(w.start, w.end) end)
          minutes = div(seconds, 60)
          %{date: date, seconds: seconds, minutes: minutes, hours: Float.round(minutes / 60, 2)}
        end)
        render(conn, :hours, rows: rows)

      "" -> user_hours(conn, %{"user_id" => user_id})

      date_string ->
        rows = TimeTracking.list_workingtimes()
        |> Enum.filter(&(&1.user_id == user_id))
        |> Enum.filter(fn w -> Date.to_iso8601(DateTime.to_date(w.start)) == date_string end)
        |> then(fn list ->
          seconds = Enum.reduce(list, 0, fn w, acc -> acc + diff_seconds(w.start, w.end) end)
          minutes = div(seconds, 60)
          [%{date: date_string, seconds: seconds, minutes: minutes, hours: Float.round(minutes / 60, 2)}]
        end)
        render(conn, :hours, rows: rows)
    end
  end

  # GET /api/charts/user/:user_id/sessions
  def user_sessions(conn, %{"user_id" => user_id}) do
    sessions = TimeTracking.list_workingtimes()
    |> Enum.filter(&(&1.user_id == user_id))
    |> Enum.map(fn w ->
      s = diff_seconds(w.start, w.end)
      %{start: w.start, end: w.end, seconds: s, minutes: div(s, 60)}
    end)
    render(conn, :sessions, sessions: sessions)
  end

  # GET /api/charts/user/:user_id/breaks
  def user_breaks(conn, %{"user_id" => user_id} = params) do
    # Breaks defined as interval between a "status=false" (out) clock and the next "status=true" (in)
    clocks = case Map.get(params, "date") do
      nil -> TimeTracking.list_clocks_for_user_asc(user_id)
      "" -> TimeTracking.list_clocks_for_user_asc(user_id)
      date -> TimeTracking.list_clocks_for_user_on_date_asc(user_id, date)
    end
    breaks = clocks
    |> Enum.reduce({[], nil}, fn c, {acc, last_out} ->
      case {c.status, last_out} do
        {false, nil} -> {acc, c.time}
        {true, nil} -> {acc, nil}
        {true, out_time} ->
          s = diff_seconds(out_time, c.time)
          {[%{start: out_time, end: c.time, seconds: s, minutes: div(s, 60)} | acc], nil}
        {false, _out_time} -> {acc, last_out}
      end
    end)
    |> elem(0)
    |> Enum.reverse()

    render(conn, :breaks, breaks: breaks)
  end

  defp diff_seconds(%DateTime{} = a, %DateTime{} = b) do
    max(0, DateTime.diff(b, a, :second))
  end
end
