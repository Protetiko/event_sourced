# frozen_string_literal: true

module EventSourced
  module Models
    Snapshot = Struct.new(
      :aggregate_id,
      :aggregate_type,
      :event_sequence,
      :created_at,
      :timestamp,
      :data,
      :version,
    )

    SnapshotValidator = Dry::Validation.Schema do
      required(:aggregate_id).filled?(:str?)
      required(:aggregate_type).filled?(:str?)
      required(:created_at).filled?(:str?)
      required(:data).filled?(:str?)
    end
  end
end
