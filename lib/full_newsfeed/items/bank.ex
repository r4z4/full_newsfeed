defmodule FullNewsfeed.Items.Bank do
  use Ecto.Schema

  @primary_key {:id, :integer, autogenerate: false}
  @foreign_key_type :integer
  schema "beer" do
    field :uid, :string
    field :account_number, :string
    field :iban, :string
    field :bank_name, :string
    field :routing_number, :string
    field :swift_bic, :string
  end
end
