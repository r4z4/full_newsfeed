defmodule FullNewsfeed.Core.Error do
  use Ecto.Schema
  alias __MODULE__

  schema "error" do
    # Use strings for atom
    field :type, :string
    field :text, :string
  end

  def to_error(object) do

    case object do
      %{"type" => type, "text" => text} -> {
        %Error{
          type: type,
          text: text,
        }
      }
      _ -> {
        "Error Creating Error Object"
      }
    end
  end

  def exception(error) do
    error.text
  end
end
