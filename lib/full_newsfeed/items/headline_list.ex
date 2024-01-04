defmodule FullNewsfeed.Items.HeadlineList do
  use Ecto.Schema
  use Ecto.Type
  alias FullNewsfeed.Items.Headline
  alias __MODULE__

  def type, do: :array

  schema "headline_list" do
    embeds_many(:headlines, Headline)
  end

  def empty?(headline_list = %HeadlineList{headlines: _}) do
    case List.first(headline_list.headlines) do
      nil -> true
      _   -> false
    end
  end

  def new(list) do
    Enum.map(list, fn hl -> Headline.new(hl) end)
  end
end
