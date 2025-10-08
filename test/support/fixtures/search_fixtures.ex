defmodule Hellophoenix.SearchFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hellophoenix.Search` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        body: "some body",
        title: "some title"
      })

    {:ok, item} = Hellophoenix.Search.create_item(scope, attrs)
    item
  end
end
