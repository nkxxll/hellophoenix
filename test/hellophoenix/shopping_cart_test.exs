defmodule Hellophoenix.ShoppingCartTest do
  use Hellophoenix.DataCase

  alias Hellophoenix.ShoppingCart

  describe "carts" do
    alias Hellophoenix.ShoppingCart.Cart

    import Hellophoenix.AccountsFixtures, only: [user_scope_fixture: 0]
    import Hellophoenix.ShoppingCartFixtures

    @invalid_attrs %{}

    test "list_carts/1 returns all scoped carts" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      cart = cart_fixture(scope)
      other_cart = cart_fixture(other_scope)
      assert ShoppingCart.list_carts(scope) == [cart]
      assert ShoppingCart.list_carts(other_scope) == [other_cart]
    end

    test "get_cart!/2 returns the cart with given id" do
      scope = user_scope_fixture()
      cart = cart_fixture(scope)
      other_scope = user_scope_fixture()
      assert ShoppingCart.get_cart!(scope, cart.id) == cart
      assert_raise Ecto.NoResultsError, fn -> ShoppingCart.get_cart!(other_scope, cart.id) end
    end

    test "create_cart/2 with valid data creates a cart" do
      valid_attrs = %{}
      scope = user_scope_fixture()

      assert {:ok, %Cart{} = cart} = ShoppingCart.create_cart(scope, valid_attrs)
      assert cart.user_id == scope.user.id
    end

    test "create_cart/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = ShoppingCart.create_cart(scope, @invalid_attrs)
    end

    test "update_cart/3 with valid data updates the cart" do
      scope = user_scope_fixture()
      cart = cart_fixture(scope)
      update_attrs = %{}

      assert {:ok, %Cart{} = cart} = ShoppingCart.update_cart(scope, cart, update_attrs)
    end

    test "update_cart/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      cart = cart_fixture(scope)

      assert_raise MatchError, fn ->
        ShoppingCart.update_cart(other_scope, cart, %{})
      end
    end

    test "update_cart/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      cart = cart_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = ShoppingCart.update_cart(scope, cart, @invalid_attrs)
      assert cart == ShoppingCart.get_cart!(scope, cart.id)
    end

    test "delete_cart/2 deletes the cart" do
      scope = user_scope_fixture()
      cart = cart_fixture(scope)
      assert {:ok, %Cart{}} = ShoppingCart.delete_cart(scope, cart)
      assert_raise Ecto.NoResultsError, fn -> ShoppingCart.get_cart!(scope, cart.id) end
    end

    test "delete_cart/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      cart = cart_fixture(scope)
      assert_raise MatchError, fn -> ShoppingCart.delete_cart(other_scope, cart) end
    end

    test "change_cart/2 returns a cart changeset" do
      scope = user_scope_fixture()
      cart = cart_fixture(scope)
      assert %Ecto.Changeset{} = ShoppingCart.change_cart(scope, cart)
    end
  end

  describe "cart_items" do
    alias Hellophoenix.ShoppingCart.CartItem

    import Hellophoenix.ShoppingCartFixtures

    @invalid_attrs %{price_when_carted: nil, quantity: nil}

    test "list_cart_items/0 returns all cart_items" do
      cart_item = cart_item_fixture()
      assert ShoppingCart.list_cart_items() == [cart_item]
    end

    test "get_cart_item!/1 returns the cart_item with given id" do
      cart_item = cart_item_fixture()
      assert ShoppingCart.get_cart_item!(cart_item.id) == cart_item
    end

    test "create_cart_item/1 with valid data creates a cart_item" do
      valid_attrs = %{price_when_carted: "120.5", quantity: 42}

      assert {:ok, %CartItem{} = cart_item} = ShoppingCart.create_cart_item(valid_attrs)
      assert cart_item.price_when_carted == Decimal.new("120.5")
      assert cart_item.quantity == 42
    end

    test "create_cart_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ShoppingCart.create_cart_item(@invalid_attrs)
    end

    test "update_cart_item/2 with valid data updates the cart_item" do
      cart_item = cart_item_fixture()
      update_attrs = %{price_when_carted: "456.7", quantity: 43}

      assert {:ok, %CartItem{} = cart_item} = ShoppingCart.update_cart_item(cart_item, update_attrs)
      assert cart_item.price_when_carted == Decimal.new("456.7")
      assert cart_item.quantity == 43
    end

    test "update_cart_item/2 with invalid data returns error changeset" do
      cart_item = cart_item_fixture()
      assert {:error, %Ecto.Changeset{}} = ShoppingCart.update_cart_item(cart_item, @invalid_attrs)
      assert cart_item == ShoppingCart.get_cart_item!(cart_item.id)
    end

    test "delete_cart_item/1 deletes the cart_item" do
      cart_item = cart_item_fixture()
      assert {:ok, %CartItem{}} = ShoppingCart.delete_cart_item(cart_item)
      assert_raise Ecto.NoResultsError, fn -> ShoppingCart.get_cart_item!(cart_item.id) end
    end

    test "change_cart_item/1 returns a cart_item changeset" do
      cart_item = cart_item_fixture()
      assert %Ecto.Changeset{} = ShoppingCart.change_cart_item(cart_item)
    end
  end
end
