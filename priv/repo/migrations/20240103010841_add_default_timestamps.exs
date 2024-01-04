defmodule FullNewsfeed.Repo.Migrations.AddDefaultTimestamps do
  use Ecto.Migration

  def change do
    alter table(:beer) do
      modify(:inserted_at, :timestamp, default: fragment("NOW()"))
    end
    alter table(:bank) do
      modify(:inserted_at, :timestamp, default: fragment("NOW()"))
    end
    alter table(:hold) do
      modify(:inserted_at, :timestamp, default: fragment("NOW()"))
    end
    alter table(:headline) do
      modify(:inserted_at, :timestamp, default: fragment("NOW()"))
    end
  end
end
