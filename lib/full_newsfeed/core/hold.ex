defmodule FullNewsfeed.Core.Hold do
  use Ecto.Schema
  import Ecto.Changeset
  alias FullNewsfeed.Core.Utils

  @primary_key {:id, :integer, autogenerate: false}
  @foreign_key_type :integer
  schema "hold" do
    field :slug, :binary_id
    field :user_id, :integer
    field :type, Ecto.Enum, values: Utils.hold_types # :upvote, :downvote, :favorite
    field :hold_cat, Ecto.Enum, values: Utils.hold_cats # :beer, :bank
    field :hold_cat_id, :integer
    field :active, :boolean
    # Custom timestamps because jfc ecto
    field :inserted_at, :naive_datetime
    field :updated_at, :naive_datetime, default: nil

    # timestamps(null: [:updated_at])
  end

  @doc false
  def changeset(hold, attrs) do
    hold
    |> cast(attrs, [:slug, :user_id, :type, :hold_cat_id, :hold_cat])
    |> validate_required([:slug, :user_id, :type, :hold_cat_id, :hold_cat])
    |> unique_constraint(:slug)
  end
end
