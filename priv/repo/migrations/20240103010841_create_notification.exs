defmodule FullNewsfeed.Repo.Migrations.CreateNotification do
  use Ecto.Migration

  def change do
    create table(:notification, primary_key: true) do
      # add :source, :jsonb, null: false
      add :about_entity, :string, null: false
      add :about_id, :integer, null: false
      add :to, {:array, :integer}, null: false
      add :subject, :string, null: false
      add :message, :string, null: false
      add :sent_at, :naive_datetime, null: false
    end
    # FIXME - Monitor performance of this with idx on `to`
    create index(:notification, [:to])
    # create unique_index(:notification, [:id], name: :notification_u_index)
  end
end
