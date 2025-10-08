defmodule Hellophoenix.SearchTest do
  use Hellophoenix.DataCase

  alias Hellophoenix.Search

  describe "items" do
    alias Hellophoenix.Search.Item

    import Hellophoenix.AccountsFixtures, only: [user_scope_fixture: 0]
    import Hellophoenix.SearchFixtures

    @invalid_attrs %{title: nil, body: nil}

    test "list_items/1 returns all scoped items" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      item = item_fixture(scope)
      other_item = item_fixture(other_scope)
      assert Search.list_items(scope) == [item]
      assert Search.list_items(other_scope) == [other_item]
    end

    test "get_item!/2 returns the item with given id" do
      scope = user_scope_fixture()
      item = item_fixture(scope)
      other_scope = user_scope_fixture()
      assert Search.get_item!(scope, item.id) == item
      assert_raise Ecto.NoResultsError, fn -> Search.get_item!(other_scope, item.id) end
    end

    test "create_item/2 with valid data creates a item" do
      valid_attrs = %{title: "some title", body: "some body"}
      scope = user_scope_fixture()

      assert {:ok, %Item{} = item} = Search.create_item(scope, valid_attrs)
      assert item.title == "some title"
      assert item.body == "some body"
      assert item.user_id == scope.user.id
    end

    test "create_item/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Search.create_item(scope, @invalid_attrs)
    end

    test "update_item/3 with valid data updates the item" do
      scope = user_scope_fixture()
      item = item_fixture(scope)
      update_attrs = %{title: "some updated title", body: "some updated body"}

      assert {:ok, %Item{} = item} = Search.update_item(scope, item, update_attrs)
      assert item.title == "some updated title"
      assert item.body == "some updated body"
    end

    test "update_item/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      item = item_fixture(scope)

      assert_raise MatchError, fn ->
        Search.update_item(other_scope, item, %{})
      end
    end

    test "update_item/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      item = item_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Search.update_item(scope, item, @invalid_attrs)
      assert item == Search.get_item!(scope, item.id)
    end

    test "delete_item/2 deletes the item" do
      scope = user_scope_fixture()
      item = item_fixture(scope)
      assert {:ok, %Item{}} = Search.delete_item(scope, item)
      assert_raise Ecto.NoResultsError, fn -> Search.get_item!(scope, item.id) end
    end

    test "delete_item/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      item = item_fixture(scope)
      assert_raise MatchError, fn -> Search.delete_item(other_scope, item) end
    end

    test "change_item/2 returns a item changeset" do
      scope = user_scope_fixture()
      item = item_fixture(scope)
      assert %Ecto.Changeset{} = Search.change_item(scope, item)
    end
  end
end
