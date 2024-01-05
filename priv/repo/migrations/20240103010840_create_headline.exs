defmodule FullNewsfeed.Repo.Migrations.CreateHeadline do
  use Ecto.Migration

  def change do
    create table(:headline, primary_key: true) do
      # add :source, :jsonb, null: false
      add :source_id, :integer, null: false
      add :author, :string, null: true
      add :title, :string, null: true
      add :description, :string, null: true
      add :url, :string, null: true
      add :urlToImage, :string, null: true
      add :publishedAt, :string, null: true
      add :content, :text, null: true
      add :inserted_at, :naive_datetime, null: false, default: fragment("NOW()")
    end
    create index(:headline, [:title])
    create unique_index(:headline, [:url, :title], name: :headline_u_index)
  end
end
