defmodule ChronoPulseWeb.WorkingTimeJSON do
  alias ChronoPulse.TimeTracking.WorkingTime

  @doc """
  Renders a list of workingtimes.
  """
  def index(%{workingtimes: workingtimes}) do
    %{data: for(working_time <- workingtimes, do: data(working_time))}
  end

  @doc """
  Renders a single working_time.
  """
  def show(%{working_time: working_time}) do
    %{data: data(working_time)}
  end

  defp data(%WorkingTime{} = working_time) do
    %{
      id: working_time.id,
      user_id: working_time.user_id,
      start: working_time.start,
      end: working_time.end
    }
  end
end
