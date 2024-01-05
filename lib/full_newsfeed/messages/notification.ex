defmodule FullNewsfeed.Messages.Notification do
  use Ecto.Schema
  alias FullNewsfeed.Core.Utils
  alias FullNewsfeed.Core.Error
  alias __MODULE__

  @subject_min 2
  @subject_max 50

  @primary_key {:id, :integer, autogenerate: false}
  @foreign_key_type :integer
  schema "notification" do
    # field :source, {:map, :string}
    field :about_entity, :string
    field :about_id, :integer
    field :to, {:array, :integer}
    field :subject, :string
    field :message, :string
    field :sent_at, :naive_datetime
  end

  @spec validate_required_fields({:map, ErrorList}) :: {arg1, arg2} when arg1: :map, arg2: ErrorList
  defp validate_required_fields({object, err_props}) do
    IO.inspect(object)
    required_fields = ["subject"]
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

  @spec validate_subject({:map, ErrorList}) :: {arg1, arg2} when arg1: :map, arg2: ErrorList
  defp validate_subject({object, err_props}) do
    name = object["name"]
    case is_binary(name) && String.length(name) in @subject_min..@subject_max do
      true -> {object, err_props}
      false ->
        err_props = Map.replace(err_props, :errors, [%Error{type: :validation, text: "Invalid Subject"} | err_props.errors])
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
          |> validate_subject()
          # |> validate_population()
        {:error, {object, err_props}} ->
          {object, err_props}
      end

    err_props = Kernel.elem(valid, 1)

    case List.first(err_props.errors) do
      # No errors, create Struct
      nil ->
        %Notification{
          about_entity: object["about_entity"],
          about_id: object["about_id"],
          to: object["to"],
          subject: object["subject"] |> String.slice(0..250),
          message: object["message"],
          sent_at: object["sent_at"],
        }
      # Return errors if errors in the error list
      _ -> err_props.errors

    end
  end
end
