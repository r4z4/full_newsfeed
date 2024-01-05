defmodule FullNewsfeed.Entities.MarketHeadlineList do
  use Ecto.Schema
  use Ecto.Type
  alias FullNewsfeed.Entities.MarketHeadline
  alias __MODULE__

  def type, do: :array

  schema "headline_list" do
    embeds_many(:headlines, MarketHeadline)
  end

  def empty?(mkt_headline_list = %MarketHeadlineList{headlines: _}) do
    case List.first(mkt_headline_list.headlines) do
      nil -> true
      _   -> false
    end
  end

  def new(list) do
    Enum.map(list, fn hl -> MarketHeadline.new(hl) end)
  end
end
