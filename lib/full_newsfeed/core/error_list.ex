defmodule FullNewsfeed.Core.ErrorList do
  use Ecto.Schema
  use Ecto.Type
  alias FullNewsfeed.Core.Error
  alias __MODULE__

  def type, do: :array

  schema "errors_object" do
    embeds_many(:errors, Error)
  end

  def empty?(error_list = %ErrorList{errors: _}) do
    case List.first(error_list.errors) do
      nil -> true
      _   -> false
    end
  end
end
