# frozen_string_literal: true

module EventSourced
  module Models
    Snapshot = Struct.new(
      :aggregate_id,
      :created_at,
      :data,
    )

    SnapshotValidator = Dry::Validation.Schema do
      required(:aggregate_id).filled?(:str?)
      required(:created_at).filled?(:str?)
      required(:data).filled?(:str?)
    end
  end
end
