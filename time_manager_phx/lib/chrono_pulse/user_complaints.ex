defmodule ChronoPulse.UserComplaints do
  @moduledoc """
  The UserComplaints context.
  """

  import Ecto.Query, warn: false
  alias ChronoPulse.Repo
  alias ChronoPulse.UserComplaints.UserComplaint

  # Create a complaint
  def create_user_complaint(attrs \\ %{}) do
    %UserComplaint{}
    |> UserComplaint.changeset(attrs)
    |> Repo.insert()
  end

  # Optional: get all complaints
  def list_user_complaints do
    Repo.all(UserComplaint)
  end

  # Optional: get complaints for one user
  def list_user_complaints_for_user(user_id) do
    Repo.all(from c in UserComplaint, where: c.user_id == ^user_id)
  end
end
