defmodule FullNewsfeed.Repo.Migrations.CreateEmbedding do
  use Ecto.Migration

  # execute "CREATE INDEX ON embedding USING hnsw (embedding vector_l2_ops) WITH (m = 4, ef_construction = 10);"

  def change do
    create table(:embedding, primary_key: true) do
      # add :source, :jsonb, null: false
      add :embedding, :vector, size: 4096
      add :prompt, :text
      add :user_id, references(:user, type: :identity, on_delete: :delete_all), null: false
      add :inserted_at, :naive_datetime, null: false, default: fragment("NOW()")
    end

    # Vectors with up to 2,000 dimensions can be indexed.
    # We have too many here
    # execute "CREATE INDEX ON embedding USING hnsw (embedding vector_l2_ops);"

  end
end
