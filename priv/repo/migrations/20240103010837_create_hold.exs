defmodule FullNewsfeed.Repo.Migrations.CreateHold do
  use Ecto.Migration

  def change do
    create table(:hold, primary_key: true) do
      add :slug, :binary_id, null: false
      add :user_id, references(:user, type: :identity, on_delete: :delete_all), null: false
      add :type, :string, null: false
      add :hold_cat_id, :binary_id, null: false
      add :hold_cat, :string, null: false
      # Most common case is adding a hold = default to true
      add :active, :boolean, null: false, default: true

      timestamps(null: [:updated_at])
    end
    create index(:hold, [:id])
    create unique_index(:hold, [:user_id, :type, :hold_cat_id, :hold_cat], name: :hold_u_index)
  end
end
