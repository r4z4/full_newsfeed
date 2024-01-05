defmodule FullNewsfeed.Repo.Migrations.CreateMarketHeadline do
  use Ecto.Migration

  def change do
    create table(:market_headline, primary_key: true) do
      # add :source, :jsonb, null: false
      add :date, :string, null: true
      add :title, :string, null: true
      add :link, :string, null: true
      add :symbols, {:array, :string}, null: true
      add :content, :string, null: true
      add :inserted_at, :naive_datetime, null: false, default: fragment("NOW()")
    end
    # FIXME Use link instead?
    create index(:market_headline, [:title])
    create unique_index(:market_headline, [:link, :title], name: :market_headline_u_index)
  end
end
