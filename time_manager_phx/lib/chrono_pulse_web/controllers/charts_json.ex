defmodule ChronoPulseWeb.ChartsJSON do
  @doc """
  Renders aggregated hours rows: [%{date, minutes, hours}]
  """
  def hours(%{rows: rows}) do
    %{data: rows}
  end

  @doc """
  Renders sessions list: [%{start, end, minutes}]
  """
  def sessions(%{sessions: sessions}) do
    %{data: sessions}
  end

  @doc """
  Renders breaks list: [%{start, end, minutes}]
  """
  def breaks(%{breaks: breaks}) do
    %{data: breaks}
  end
end
