defmodule HellophoenixWeb.HelloController do
  use HellophoenixWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def show(conn, %{"messenger" => messenger}) do
    conn
    |> assign(:messenger, messenger)
    |> assign(:message, "This is the message for: ")
    |> render(:show)
  end
end
