defmodule HellophoenixWeb.CartController do
  use HellophoenixWeb, :controller

  alias Hellophoenix.ShoppingCart

  def show(conn, _params) do
    render(conn, :show,
      changeset: ShoppingCart.change_cart(conn.assigns.current_scope, conn.assigns.cart)
    )
  end
end
