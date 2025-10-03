defmodule HellophoenixWeb.UserSessionHTML do
  use HellophoenixWeb, :html

  embed_templates "user_session_html/*"

  defp local_mail_adapter? do
    Application.get_env(:hellophoenix, Hellophoenix.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
