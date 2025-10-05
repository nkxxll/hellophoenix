defmodule Hellophoenix.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :total_price, :decimal, precision: 15, scale: 6, null: false
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:orders, [:user_id])
  end
end
