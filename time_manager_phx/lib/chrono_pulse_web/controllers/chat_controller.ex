defmodule ChronoPulseWeb.ChatController do
  use ChronoPulseWeb, :controller
  alias ChronoPulse.OpenAIClient

  def create(conn, %{"messages" => messages}) do
    case OpenAIClient.chat(messages) do
      {:ok, %Tesla.Env{status: 200, body: %{"choices" => [%{"message" => reply}]}}} ->
        json(conn, %{reply: reply["content"]})

      {:ok, %Tesla.Env{status: status, body: body}} ->
        conn
        |> put_status(status)
        |> json(%{error: body})

      {:error, reason} ->
        conn
        |> put_status(500)
        |> json(%{error: reason})
    end
  end
end
