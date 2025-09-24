defmodule HellophoenixWeb.PageController do
  use HellophoenixWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def other(conn, _params) do
    render(conn, :other)
  end
end
