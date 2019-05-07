# frozen_string_literal: true

require 'ostruct'

module EventSourced
  module Models
    AggregateRecord = OpenStruct
    # .new(
    #   :id,
    #   :type,
    #   :created_at,
    #   :last_snapshot_id,
    # )
  end
end
