defmodule ChronoPulseWeb.UserComplaintController do
  use ChronoPulseWeb, :controller

  alias ChronoPulse.UserComplaints

  def create(conn, %{"user_id" => user_id, "complaint" => complaint}) do
    case UserComplaints.create_user_complaint(%{user_id: user_id, complaint: complaint}) do
      {:ok, user_complaint} ->
        json(conn, %{status: "success", complaint: user_complaint})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", errors: translate_errors(changeset)})
    end
  end

  # helper function to make errors JSON-encodable
  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
