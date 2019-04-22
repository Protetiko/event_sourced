# frozen_string_literal: true

module EventSourced
  module Models
    Aggregate = Struct.new(
      :aggregate_id,
      :aggregate_type,
      :created_at,
    )

    AggregateValidator = Dry::Validation.Schema do
      required(:aggregate_id).filled?(:str?)
      required(:aggregate_type).filled?(:str?)
    end
  end
end
