defmodule Hellophoenix.Accounts do
  import Ecto.Query, warn: false
  alias Hellophoenix.Repo
  alias Hellophoenix.User

  @spec get_user(integer()) :: User
  def get_user(id) do
    case Repo.one(from u in User, where: u.id == ^id) do
      nil -> {:error, nil}
      user -> {:ok, user}
    end
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
