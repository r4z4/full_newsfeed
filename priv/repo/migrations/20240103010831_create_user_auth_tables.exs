defmodule FullNewsFeed.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:user, primary_key: true) do
      add :slug, :binary_id, null: false
      add :username, :string, null: false, default: false
      add :email, :citext, null: false
      add :role, :string, null: false, default: "reader"
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      timestamps(null: [:updated_at])
    end

    create unique_index(:user, [:email])

    create table(:user_token, primary_key: true) do
      add :user_id, references(:user, type: :identity, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:user_token, [:user_id])
    create unique_index(:user_token, [:context, :token])
  end
end
