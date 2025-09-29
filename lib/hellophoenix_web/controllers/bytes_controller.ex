defmodule HellophoenixWeb.BytesController do
  use HellophoenixWeb, :controller

  def direct(conn, _params) do
    send_resp(conn, 201, "")
  end
end
