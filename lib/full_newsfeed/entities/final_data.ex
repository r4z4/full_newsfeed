defmodule FullNewsfeed.Entities.FinalData do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
      # field :context, {:array, :integer}
      # field :created_at, :naive_datetime
      # field :done, :boolean
      # field :eval_count, :integer
      field :eval_duration, :integer
      # field :load_duration, :integer
      field :model, :string
      # field :prompt_eval_count, :integer
      field :prompt_eval_duration, :integer
      # field :response, :string
      field :total_duration, :integer
  end
end
