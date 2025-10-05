defmodule HellophoenixWeb.OrderController do
  use HellophoenixWeb, :controller

  alias Hellophoenix.Orders

  def show(conn, %{"id" => id}) do
    order = Orders.get_order!(conn.assigns.current_scope, id)
    render(conn, :show, order: order)
  end

  def create(conn, _) do
    case Orders.complete_order(conn.assigns.current_scope, conn.assigns.cart) do
      {:ok, order} ->
        conn
        |> put_flash(:info, "Order created successfully.")
        |> redirect(to: ~p"/orders/#{order}")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "There was an error processing your order")
        |> redirect(to: ~p"/cart")
    end
  end
end
