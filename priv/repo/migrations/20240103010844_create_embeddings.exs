defmodule FullNewsfeed.Repo.Migrations.CreateEmbedding do
  use Ecto.Migration

  def change do
    create table(:embedding, primary_key: true) do
      # add :source, :jsonb, null: false
      add :embedding, :vector, size: 4096
      add :user_id, references(:user, type: :identity, on_delete: :delete_all), null: false
      add :inserted_at, :naive_datetime, null: false, default: fragment("NOW()")
    end
  end
end
