defmodule FullNewsfeed.Items.Beer do
  use Ecto.Schema
  alias FullNewsfeed.Core.Utils
  alias FullNewsfeed.Core.Error
  alias __MODULE__

  @name_min 2
  @name_max 50

  @primary_key {:id, :integer, autogenerate: false}
  @foreign_key_type :integer
  schema "beer" do
    field :uid, :string
    field :brand, :string
    field :name, :string
    field :style, :string
    field :hop, :string
    field :yeast, :string
    field :malts, :string
    field :ibu, :string
    field :alcohol, :string
    field :blg, :string
  end

  @spec validate_required_fields({:map, ErrorList}) :: {arg1, arg2} when arg1: :map, arg2: ErrorList
  defp validate_required_fields({object, err_props}) do
    IO.inspect(object)
    required_fields = ["name", "uid", "brand"]
    missing = Enum.map(required_fields, fn field ->
      res = Map.fetch(object, field)
      # IO.inspect(res, label: "Res")
      case res do
        {:ok, nil} -> field
        {:ok, _val} -> nil
        :error -> field
        _ -> field
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

  @spec validate_name({:map, ErrorList}) :: {arg1, arg2} when arg1: :map, arg2: ErrorList
  defp validate_name({object, err_props}) do
    name = object["name"]
    case is_binary(name) && String.length(name) in @name_min..@name_max do
      true -> {object, err_props}
      false ->
        err_props = Map.replace(err_props, :errors, [%Error{type: :validation, text: "Invalid Name"} | err_props.errors])
        {object, err_props}
    end
  end

  # @spec validate_population({:map, ErrorList}) :: {arg1, arg2} when arg1: :map, arg2: ErrorList
  # defp validate_population({object, err_props}) do
  #   population = object[:population]
  #   case is_integer(population) do
  #     true ->
  #       case population in @pop_min..@pop_max do
  #         true -> {object, err_props}
  #         false ->
  #           err_props = Map.replace(err_props, :errors, [%Error{type: :validation, text: "Invalid Population Size"} | err_props.errors])
  #           {object, err_props}
  #       end
  #     false ->
  #       err_props = Map.replace(err_props, :errors, [%Error{type: :validation, text: "Invalid Population Type"} | err_props.errors])
  #       {object, err_props}
  #   end
  # end

  def new(object) do
    err_props = %{:errors => []}
    valid =
      case validate_required_fields({object, err_props}) do
        # Only further validate if the fields are present. Avoids a nil check in each.
        {:ok, {object, err_props}} ->
          {object, err_props}
          |> validate_name()
          # |> validate_population()
        {:error, {object, err_props}} ->
          {object, err_props}
      end

    err_props = Kernel.elem(valid, 1)

    case List.first(err_props.errors) do
      # No errors, create Struct
      nil ->
        %Beer{
          # id: object["id"],
          uid: object["uid"],
          brand: object["brand"],
          name: object["name"],
          style: object["style"],
          hop: object["hop"],
          yeast: object["yeast"],
          malts: object["malts"],
          ibu: object["ibu"],
          alcohol: object["alcohol"],
          blg: object["blg"]
        }
      # Return errors if errors in the error list
      _ -> err_props.errors

    end
  end
end
