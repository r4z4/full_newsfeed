defmodule FullNewsfeed.Entities.MarketHeadline do
  use Ecto.Schema
  alias FullNewsfeed.Core.Utils
  alias FullNewsfeed.Core.Error
  alias __MODULE__

  @name_min 2
  @name_max 50

  @primary_key {:id, :integer, autogenerate: false}
  @foreign_key_type :integer
  schema "market_headline" do
    # field :source, {:map, :string}
    field :date, :string
    field :title, :string
    field :link, :string
    field :symbols, {:array, :string}
    field :content, :string
    # Custom timestamps because jfc ecto
    field :inserted_at, :naive_datetime
    # We will never edit a headline
    # field :updated_at, :naive_datetime, default: nil
  end

  @spec validate_required_fields({:map, ErrorList}) :: {arg1, arg2} when arg1: :map, arg2: ErrorList
  defp validate_required_fields({object, err_props}) do
    IO.inspect(object)
    required_fields = ["date", "link"]
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

  @spec validate_url({:map, ErrorList}) :: {arg1, arg2} when arg1: :map, arg2: ErrorList
  defp validate_url({object, err_props}) do
    url = object["link"]
    pattern = ~r/^([a-z][a-z0-9\*\-\.]*):\/\/(?:(?:(?:[\w\.\-\+!$&'\(\)*\+,;=]|%[0-9a-f]{2})+:)*(?:[\w\.\-\+%!$&'\(\)*\+,;=]|%[0-9a-f]{2})+@)?(?:(?:[a-z0-9\-\.]|%[0-9a-f]{2})+|(?:\[(?:[0-9a-f]{0,4}:)*(?:[0-9a-f]{0,4})\]))(?::[0-9]+)?(?:[\/|\?](?:[\w#!:\.\?\+=&@!$'~*,;\/\(\)\[\]\-]|%[0-9a-f]{2})*)?$/
    valid = String.match?(url, pattern)
    case valid do
      true -> {object, err_props}
      false ->
        err_props = Map.replace(err_props, :errors, [%Error{type: :validation, text: "Invalid Link"} | err_props.errors])
        {object, err_props}
    end
  end

  def get_source_id(%{"id" => id, "name" => name}) do
    case id do
      "associated-press" -> 1
      "bbc-news" -> 2
      _ -> 0
    end
  end

  def display_source(id) do
    case id do
      1 -> "AP"
      2 -> "BBS"
      _ -> "Other"
    end
  end

  def new(object) do
    err_props = %{:errors => []}
    valid =
      case validate_required_fields({object, err_props}) do
        # Only further validate if the fields are present. Avoids a nil check in each.
        {:ok, {object, err_props}} ->
          {object, err_props}
          |> validate_url()
          # |> validate_population()
        {:error, {object, err_props}} ->
          {object, err_props}
      end

    err_props = Kernel.elem(valid, 1)

    case List.first(err_props.errors) do
      # No errors, create Struct
      nil ->
        %MarketHeadline{
          # id: object["id"],
          date: object["date"],
          title: object["title"],
          link: object["link"],
          symbols: object["symbols"],
          content: object["content"]
        }
      # Return errors if errors in the error list
      _ -> err_props.errors

    end
  end
end
