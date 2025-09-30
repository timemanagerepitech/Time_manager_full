defmodule ChronoPulse.Repo.Migrations.CreateUserComplaints do
  use Ecto.Migration

  def change do
    create table(:user_complaints, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :complaint, :text
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:user_complaints, [:user_id])
  end
end
