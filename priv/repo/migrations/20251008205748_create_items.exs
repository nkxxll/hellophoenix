defmodule Hellophoenix.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :title, :string
      add :body, :string
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:items, [:user_id])
  end
end
