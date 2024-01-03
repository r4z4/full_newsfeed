defmodule FullNewsfeed.Repo do
  use Ecto.Repo,
    otp_app: :full_newsfeed,
    adapter: Ecto.Adapters.Postgres
end
