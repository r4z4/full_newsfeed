defmodule FullNewsfeed.Entities.Embedding do
  use Ecto.Schema
  alias __MODULE__

  @name_min 2
  @name_max 50

  @primary_key {:id, :integer, autogenerate: false}
  @foreign_key_type :integer
  schema "embedding" do
    field :embedding, Pgvector.Ecto.Vector
    field :prompt, :string
    field :user_id, :integer
    field :inserted_at, :naive_datetime
  end
end
