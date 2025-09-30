defmodule HellophoenixWeb.UserController do
  use HellophoenixWeb, :controller

  alias Hellophoenix.User

  def index(conn, _params) do
    users = Hellophoenix.Repo.all(User)
    render(conn, :index, users: users)
  end

  def new(conn, _params) do
    changeset = Hellophoenix.Accounts.change_user(%User{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Hellophoenix.Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: ~p"/users/#{user.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    case Hellophoenix.Accounts.get_user(id) do
      {:ok, user} ->
        conn
        |> assign(:user, user)
        |> render(:show)

      {:error, _} ->
        conn
        |> put_flash(:error, "user with id #{id} could not be found")
        |> redirect(to: ~p"/users")
    end
  end
end
