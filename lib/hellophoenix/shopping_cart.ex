defmodule Hellophoenix.ShoppingCart do
  @moduledoc """
  The ShoppingCart context.
  """

  import Ecto.Query, warn: false
  alias Hellophoenix.Repo

  alias Hellophoenix.Catalog
  alias Hellophoenix.ShoppingCart.{Cart, CartItem}
  alias Hellophoenix.Accounts.Scope

  def total_item_price(%CartItem{} = item) do
    Decimal.mult(item.product.price, item.quantity)
  end

  def total_cart_price(%Cart{} = cart) do
    Enum.reduce(cart.items, 0, fn item, acc ->
      item
      |> total_item_price()
      |> Decimal.add(acc)
    end)
  end

  def get_cart(%Scope{} = scope) do
    Repo.one(
      from(c in Cart,
        where: c.user_id == ^scope.user.id,
        left_join: i in assoc(c, :items),
        left_join: p in assoc(i, :product),
        order_by: [asc: i.inserted_at],
        preload: [items: {i, product: p}]
      )
    )
  end

  @doc """
  Subscribes to scoped notifications about any cart changes.

  The broadcasted messages match the pattern:

    * {:created, %Cart{}}
    * {:updated, %Cart{}}
    * {:deleted, %Cart{}}

  """
  def subscribe_carts(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Hellophoenix.PubSub, "user:#{key}:carts")
  end

  defp broadcast_cart(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Hellophoenix.PubSub, "user:#{key}:carts", message)
  end

  @doc """
  Returns the list of carts.

  ## Examples

      iex> list_carts(scope)
      [%Cart{}, ...]

  """
  def list_carts(%Scope{} = scope) do
    Repo.all_by(Cart, user_id: scope.user.id)
  end

  @doc """
  Gets a single cart.

  Raises `Ecto.NoResultsError` if the Cart does not exist.

  ## Examples

      iex> get_cart!(scope, 123)
      %Cart{}

      iex> get_cart!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_cart!(%Scope{} = scope, id) do
    Repo.get_by!(Cart, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a cart.

  ## Examples

      iex> create_cart(scope, %{field: value})
      {:ok, %Cart{}}

      iex> create_cart(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cart(%Scope{} = scope, attrs) do
    with {:ok, cart = %Cart{}} <-
           %Cart{}
           |> Cart.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_cart(scope, {:created, cart})
      {:ok, get_cart(scope)}
    end
  end

  @doc """
  Updates a cart.

  ## Examples

      iex> update_cart(scope, cart, %{field: new_value})
      {:ok, %Cart{}}

      iex> update_cart(scope, cart, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cart(%Scope{} = scope, %Cart{} = cart, attrs) do
    true = cart.user_id == scope.user.id

    changeset =
      cart
      |> Cart.changeset(attrs, scope)
      |> Ecto.Changeset.cast_assoc(:items, with: &CartItem.changeset/2)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:cart, changeset)
    |> Ecto.Multi.delete_all(:discarded_items, fn %{cart: cart} ->
      from(i in CartItem, where: i.cart_id == ^cart.id and i.quantity == 0)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{cart: cart}} ->
        broadcast(scope, {:updated, cart})
        {:ok, cart}

      {:error, :cart, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a cart.

  ## Examples

      iex> delete_cart(scope, cart)
      {:ok, %Cart{}}

      iex> delete_cart(scope, cart)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cart(%Scope{} = scope, %Cart{} = cart) do
    true = cart.user_id == scope.user.id

    with {:ok, cart = %Cart{}} <-
           Repo.delete(cart) do
      broadcast_cart(scope, {:deleted, cart})
      {:ok, cart}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cart changes.

  ## Examples

      iex> change_cart(scope, cart)
      %Ecto.Changeset{data: %Cart{}}

  """
  def change_cart(%Scope{} = scope, %Cart{} = cart, attrs \\ %{}) do
    true = cart.user_id == scope.user.id

    Cart.changeset(cart, attrs, scope)
  end

  alias Hellophoenix.ShoppingCart.CartItem

  @doc """
  Returns the list of cart_items.

  ## Examples

      iex> list_cart_items()
      [%CartItem{}, ...]

  """
  def list_cart_items do
    Repo.all(CartItem)
  end

  @doc """
  Gets a single cart_item.

  Raises `Ecto.NoResultsError` if the Cart item does not exist.

  ## Examples

      iex> get_cart_item!(123)
      %CartItem{}

      iex> get_cart_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cart_item!(id), do: Repo.get!(CartItem, id)

  @doc """
  Creates a cart_item.

  ## Examples

      iex> create_cart_item(%{field: value})
      {:ok, %CartItem{}}

      iex> create_cart_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cart_item(attrs) do
    %CartItem{}
    |> CartItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cart_item.

  ## Examples

      iex> update_cart_item(cart_item, %{field: new_value})
      {:ok, %CartItem{}}

      iex> update_cart_item(cart_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cart_item(%CartItem{} = cart_item, attrs) do
    cart_item
    |> CartItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cart_item.

  ## Examples

      iex> delete_cart_item(cart_item)
      {:ok, %CartItem{}}

      iex> delete_cart_item(cart_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cart_item(%CartItem{} = cart_item) do
    Repo.delete(cart_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cart_item changes.

  ## Examples

      iex> change_cart_item(cart_item)
      %Ecto.Changeset{data: %CartItem{}}

  """
  def change_cart_item(%CartItem{} = cart_item, attrs \\ %{}) do
    CartItem.changeset(cart_item, attrs)
  end

  def add_item_to_cart(%Scope{} = scope, %Cart{} = cart, product_id) do
    true = cart.user_id == scope.user.id
    product = Catalog.get_product!(product_id)

    %CartItem{quantity: 1, price_when_carted: product.price}
    |> CartItem.changeset(%{})
    |> Ecto.Changeset.put_assoc(:cart, cart)
    |> Ecto.Changeset.put_assoc(:product, product)
    |> Repo.insert(
      on_conflict: [inc: [quantity: 1]],
      conflict_target: [:cart_id, :product_id]
    )
  end

  def remove_item_from_cart(%Scope{} = scope, %Cart{} = cart, product_id) do
    true = cart.user_id == scope.user.id

    {1, _} =
      Repo.delete_all(
        from(i in CartItem,
          where: i.cart_id == ^cart.id,
          where: i.product_id == ^product_id
        )
      )

    {:ok, get_cart(scope)}
  end
end
