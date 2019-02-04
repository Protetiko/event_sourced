module EventSourced
  module Models
    Event = Struct.new(
      :aggregate_id,
      :aggregate_type,
      :sequence,
      :event_type,
      :command_id,
      :correlation_id,
      :causation_id,
      :timestamp,
      :data,
      :meta_data,
      :event_version,
    )

    EventValidator = Dry::Validation.Schema do
      required(:aggregate_id).filled?(:str?)
      required(:aggregate_type).filled?(:str?)
      required(:sequence).filled?(:int?)
      required(:event_type).filled?(:str?)
      required(:command_id).filled?(:str?)
      required(:correlation_id).filled?(:str?)
      required(:causation_id).filled?(:str?)
      required(:timestamp).filled?(:str?)
      required(:data).filled?(:hash?)
      required(:meta_data).filled?(:hash?)
    end
  end
end
