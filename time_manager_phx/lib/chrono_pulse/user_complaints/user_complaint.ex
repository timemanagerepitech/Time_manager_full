defmodule ChronoPulse.UserComplaints.UserComplaint do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Jason.Encoder, only: [:id, :user_id, :complaint, :inserted_at, :updated_at]}
  schema "user_complaints" do
    field :complaint, :string
    belongs_to :user, ChronoPulse.Users.User, type: :binary_id

    timestamps()
  end

  def changeset(user_complaint, attrs) do
    user_complaint
    |> cast(attrs, [:user_id, :complaint])
    |> validate_required([:user_id, :complaint])
  end
end
