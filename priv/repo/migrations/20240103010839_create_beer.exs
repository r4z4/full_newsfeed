defmodule FullNewsfeed.Repo.Migrations.CreateBeer do
  use Ecto.Migration

  def change do
    create table(:beer, primary_key: true) do
      add :uid, :binary_id, null: false
      add :brand, :string, null: false
      add :name, :string, null: false
      add :style, :string, null: false
      add :hop, :string, null: false
      add :yeast, :string, null: false
      add :malts, :string, null: false
      add :ibu, :string, null: false
      add :alcohol, :string, null: false
      add :blg, :string, null: false

      timestamps(null: [:updated_at])
    end
    create index(:beer, [:name])
    create unique_index(:beer, [:uid, :name], name: :beer_u_index)
  end
end
