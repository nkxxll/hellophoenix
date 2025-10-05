defmodule Hellophoenix.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :total_price, :decimal

    belongs_to :user, Hellophoenix.Accounts.User
    has_many :line_items, Hellophoenix.Orders.LineItem
    has_many :products, through: [:line_items, :product]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs, user_scope) do
    order
    |> cast(attrs, [:total_price])
    |> validate_required([:total_price])
    |> put_change(:user_id, user_scope.user.id)
  end
end
