defmodule FullNewsfeed.Entities.Bank do
  use Ecto.Schema
  alias __MODULE__
  alias Ecto.UUID
  alias FullNewsfeed.Core.Utils
  alias FullNewsfeed.Core.Error
  alias FullNewsfeed.Core.ErrorList

  # Not sure why they have 10 len acct #s
  @routing_num_len 9
  @acct_num_len 10

  @primary_key {:id, :integer, autogenerate: false}
  @foreign_key_type :integer
  schema "bank" do
    field :uid, :string
    field :account_number_nacl, :string
    field :iban, :string
    field :bank_name, :string
    field :routing_number_nacl, :string
    field :swift_bic, :string
    # Custom timestamps because jfc ecto
    field :inserted_at, :naive_datetime
    field :updated_at, :naive_datetime, default: nil
  end

  @spec validate_required_fields({:map, %{:errors => []}}) :: {:error, {:map, map()}} | {:ok, {:map, map()}}
  defp validate_required_fields({object, err_props}) do
    IO.inspect(object)
    required_fields = ["uid", "account_number"]
    missing = Enum.map(required_fields, fn field ->
      res = Map.fetch(object, field)
      # IO.inspect(res, label: "Res")
      case res do
        {:ok, nil} -> field
        {:ok, _val} -> nil
        :error -> field
      end
    end)
    # IO.inspect(missing, label: "Missing")
    case Enum.any?(missing) do
      false -> {:ok, {object, err_props}}
      true  ->
        err_props = Map.replace(err_props, :errors, [%Error{type: :validation, text: "Missing Fields: #{Utils.display_missing_fields(missing)}"} | err_props.errors])
        {:error, {object, err_props}}
    end
  end

  @spec validate_account_number({map(), %{:errors => []}}) :: {map(), map()}
  defp validate_account_number({object, err_props}) do
    account_number = object["account_number"]
    case is_binary(account_number) && String.length(account_number) == @acct_num_len do
      true -> {object, err_props}
      false ->
        err_props = Map.replace(err_props, :errors, [%Error{type: :validation, text: "Invalid Account Number"} | err_props.errors])
        {object, err_props}
    end
  end

  @spec validate_routing_number({map(), %{:errors => []}}) :: {map(), map()}
  defp validate_routing_number({object, err_props}) do
    routing_number = object["routing_number"]
    case is_binary(routing_number) && String.length(routing_number) == @routing_num_len do
      true -> {object, err_props}
      false ->
        err_props = Map.replace(err_props, :errors, [%Error{type: :validation, text: "Invalid Name"} | err_props.errors])
        {object, err_props}
    end
  end

  def new(object) do
    err_props = %{:errors => []}
    valid =
      case validate_required_fields({object, err_props}) do
        # Only further validate if the fields are present. Avoids a nil check in each.
        {:ok, {object, err_props}} ->
          {object, err_props}
          |> validate_account_number()
          |> validate_routing_number()
          # |> validate_population()
        {:error, {object, err_props}} ->
          {object, err_props}
      end

    err_props = Kernel.elem(valid, 1)

    case List.first(err_props.errors) do
      # No errors, create Struct
      nil ->
        enc_routing = Plug.Crypto.encrypt(System.get_env("SHA_KEY"), System.get_env("BANK_SALT"), object["routing_number"])
        enc_account = Plug.Crypto.encrypt(System.get_env("SHA_KEY"), System.get_env("BANK_SALT"), object["account_number"])
        %Bank{
          # id: object["id"],
          uid: UUID.dump!(object["uid"]),
          account_number_nacl: enc_account,
          iban: object["iban"],
          bank_name: object["bank_name"],
          routing_number_nacl: enc_routing,
          swift_bic: object["swift_bic"]
        }
      # Return errors if errors in the error list
      _ -> err_props.errors

    end
  end
end
