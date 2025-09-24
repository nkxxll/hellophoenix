defmodule Hellophoenix.Repo do
  use Ecto.Repo,
    otp_app: :hellophoenix,
    adapter: Ecto.Adapters.SQLite3
end
