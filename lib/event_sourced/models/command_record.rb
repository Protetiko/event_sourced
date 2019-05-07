# frozen_string_literal: true

require 'ostruct'

module EventSourced
  module Models
    Command = OpenStruct
    # .new(
    #   :aggregate_id,
    #   :aggregate_type,
    #   :command_id,
    #   :type,
    #   :correlation_id,
    #   :causation_id,
    #   :data,
    #   :meta_data,
    #   :created_at,
    # )
  end
end
