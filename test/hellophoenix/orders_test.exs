defmodule Hellophoenix.OrdersTest do
  use Hellophoenix.DataCase

  alias Hellophoenix.Orders

  describe "orders" do
    alias Hellophoenix.Orders.Order

    import Hellophoenix.AccountsFixtures, only: [user_scope_fixture: 0]
    import Hellophoenix.OrdersFixtures

    @invalid_attrs %{total_price: nil}

    test "list_orders/1 returns all scoped orders" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      order = order_fixture(scope)
      other_order = order_fixture(other_scope)
      assert Orders.list_orders(scope) == [order]
      assert Orders.list_orders(other_scope) == [other_order]
    end

    test "get_order!/2 returns the order with given id" do
      scope = user_scope_fixture()
      order = order_fixture(scope)
      other_scope = user_scope_fixture()
      assert Orders.get_order!(scope, order.id) == order
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(other_scope, order.id) end
    end

    test "create_order/2 with valid data creates a order" do
      valid_attrs = %{total_price: "120.5"}
      scope = user_scope_fixture()

      assert {:ok, %Order{} = order} = Orders.create_order(scope, valid_attrs)
      assert order.total_price == Decimal.new("120.5")
      assert order.user_id == scope.user.id
    end

    test "create_order/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(scope, @invalid_attrs)
    end

    test "update_order/3 with valid data updates the order" do
      scope = user_scope_fixture()
      order = order_fixture(scope)
      update_attrs = %{total_price: "456.7"}

      assert {:ok, %Order{} = order} = Orders.update_order(scope, order, update_attrs)
      assert order.total_price == Decimal.new("456.7")
    end

    test "update_order/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      order = order_fixture(scope)

      assert_raise MatchError, fn ->
        Orders.update_order(other_scope, order, %{})
      end
    end

    test "update_order/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      order = order_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(scope, order, @invalid_attrs)
      assert order == Orders.get_order!(scope, order.id)
    end

    test "delete_order/2 deletes the order" do
      scope = user_scope_fixture()
      order = order_fixture(scope)
      assert {:ok, %Order{}} = Orders.delete_order(scope, order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(scope, order.id) end
    end

    test "delete_order/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      order = order_fixture(scope)
      assert_raise MatchError, fn -> Orders.delete_order(other_scope, order) end
    end

    test "change_order/2 returns a order changeset" do
      scope = user_scope_fixture()
      order = order_fixture(scope)
      assert %Ecto.Changeset{} = Orders.change_order(scope, order)
    end
  end

  describe "order_line_items" do
    alias Hellophoenix.Orders.LineItem

    import Hellophoenix.OrdersFixtures

    @invalid_attrs %{price: nil, quantity: nil}

    test "list_order_line_items/0 returns all order_line_items" do
      line_item = line_item_fixture()
      assert Orders.list_order_line_items() == [line_item]
    end

    test "get_line_item!/1 returns the line_item with given id" do
      line_item = line_item_fixture()
      assert Orders.get_line_item!(line_item.id) == line_item
    end

    test "create_line_item/1 with valid data creates a line_item" do
      valid_attrs = %{price: "120.5", quantity: 42}

      assert {:ok, %LineItem{} = line_item} = Orders.create_line_item(valid_attrs)
      assert line_item.price == Decimal.new("120.5")
      assert line_item.quantity == 42
    end

    test "create_line_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_line_item(@invalid_attrs)
    end

    test "update_line_item/2 with valid data updates the line_item" do
      line_item = line_item_fixture()
      update_attrs = %{price: "456.7", quantity: 43}

      assert {:ok, %LineItem{} = line_item} = Orders.update_line_item(line_item, update_attrs)
      assert line_item.price == Decimal.new("456.7")
      assert line_item.quantity == 43
    end

    test "update_line_item/2 with invalid data returns error changeset" do
      line_item = line_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_line_item(line_item, @invalid_attrs)
      assert line_item == Orders.get_line_item!(line_item.id)
    end

    test "delete_line_item/1 deletes the line_item" do
      line_item = line_item_fixture()
      assert {:ok, %LineItem{}} = Orders.delete_line_item(line_item)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_line_item!(line_item.id) end
    end

    test "change_line_item/1 returns a line_item changeset" do
      line_item = line_item_fixture()
      assert %Ecto.Changeset{} = Orders.change_line_item(line_item)
    end
  end
end
