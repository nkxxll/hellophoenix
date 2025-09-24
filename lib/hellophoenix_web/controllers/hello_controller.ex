defmodule HellophoenixWeb.HelloController do
  use HellophoenixWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

end
