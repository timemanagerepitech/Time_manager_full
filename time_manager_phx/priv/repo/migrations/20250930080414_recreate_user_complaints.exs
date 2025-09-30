defmodule ChronoPulse.Repo.Migrations.RecreateUserComplaints do
  use Ecto.Migration

  def change do
    drop table(:user_complaints)

    create table(:user_complaints, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :complaint, :text, null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_complaints, [:user_id])
  end
end
