defmodule FullNewsfeed.Repo.Migrations.CreateBank do
  use Ecto.Migration

  def change do
    create table(:bank, primary_key: true) do
      add :uid, :binary_id, null: false
      add :account_number_nacl, :string, null: false
      add :iban, :string, null: false
      add :bank_name, :string, null: false
      add :routing_number_nacl, :string, null: false
      add :swift_bic, :string, null: false
      add :inserted_at, :naive_datetime, null: false, default: fragment("NOW()")
      add :updated_at, :naive_datetime, null: true, default: nil
    end
    create index(:bank, [:bank_name])
    create unique_index(:bank, [:uid, :bank_name], name: :bank_u_index)
  end
end
