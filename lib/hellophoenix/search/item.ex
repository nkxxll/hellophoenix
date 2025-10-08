defmodule Hellophoenix.Search.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :title, :string
    field :body, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs, user_scope) do
    item
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
    |> put_change(:user_id, user_scope.user.id)
  end
end
