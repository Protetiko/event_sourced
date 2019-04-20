# frozen_string_literal: true

require 'event_sourced/message'

module EventSourced
  class Command
    include EventSourced::Message

    attr_accessor :command_id
    attr_accessor :aggregate_id
    attr_accessor :command_type
    attr_accessor :data
    attr_accessor :meta_data
    attr_accessor :timestamp
    attr_accessor :command_version
    attr_accessor :correlation_id
    attr_accessor :causation_id

    def initialize(command_message)
      self.aggregate_id    = command_message[:aggregate_id]
      self.command_id      = command_message[:command_id] || UUID.generate
      self.correlation_id  = command_message[:correlation_id] || self.command_id
      self.causation_id    = command_message[:causation_id] || self.command_id
      self.command_type    = self.class.name
      self.timestamp       = Time.now
      self.command_version = 1
      self.meta_data       = command_message[:meta_data]

      # Set the internal `attributes` variable
      self.instance_exec(command_message[:data], &self.class._builder) if self.class._builder
      self.data            = attributes
    end

    def to_h
      {
        aggregate_id:    aggregate_id,
        command_id:      command_id,
        command_type:    command_type,
        timestamp:       timestamp,
        command_version: command_version,
        correlation_id:  correlation_id,
        causation_id:    causation_id,
        meta_data:       meta_data,
        data:            attributes,
      }
    end
  end
end
