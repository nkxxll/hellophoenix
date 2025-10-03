defmodule HellophoenixWeb.CartHTML do
  use HellophoenixWeb, :html

  alias Hello.ShoppingCart

  embed_templates "cart_html/*"

  def currency_to_str(%Decimal{} = val), do: "$#{Decimal.round(val, 2)}"
end
