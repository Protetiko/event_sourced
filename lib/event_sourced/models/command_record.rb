# frozen_string_literal: true

module EventSourced
  module Models
    Command = Struct.new(
      :aggregate_id,
      :aggregate_type,
      :command_id,
      :type,
      :correlation_id,
      :causation_id,
      :data,
      :meta_data,
      :created_at,
      :version,
    )

    CommandValidator = Dry::Validation.Schema do
      required(:command_id).filled?(:str?)
      required(:aggregate_id).filled?(:str?)
      required(:type).filled?(:str?)
      required(:data).filled?(:hash?)
      required(:meta_data).filled?(:hash?)
      required(:created_at).filled?(:str?)
    end
  end
end
