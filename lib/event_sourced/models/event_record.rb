# frozen_string_literal: true

require 'ostruct'

module EventSourced
  module Models
    Event = OpenStruct
    # .new(
    #   :aggregate_id,
    #   :aggregate_type,
    #   :sequence_number,
    #   :type,
    #   :command_id,
    #   :correlation_id,
    #   :causation_id,
    #   :timestamp,
    #   :data,
    #   :meta_data,
    # )
  end
end
