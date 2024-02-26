defmodule FullNewsfeed.Repo.Migrations.CreateVectorExtension do
  use Ecto.Migration

  # Hierarchical Navigable Small World

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS vector"
  end

  def down do
    execute "DROP EXTENSION vector"
  end
end
