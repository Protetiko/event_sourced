# frozen_string_literal: true

require 'event_sourced/message'

module EventSourced
  class Event
    include EventSourced::Message

    EventValidationFailed = Class.new(StandardError)

    attr_accessor :command_id
    attr_accessor :aggregate_id
    attr_accessor :event_id
    attr_accessor :data
    attr_accessor :meta_data
    attr_accessor :timestamp
    attr_accessor :event_version
    attr_accessor :correlation_id
    attr_accessor :causation_id

    def initialize(event_message = {})
      result = Validators::EventValidator.call(event_message)
      raise(EventValidationFailed, result.errors) if result.failure?
      event_message = result.output

      self.aggregate_id    = event_message[:aggregate_id]
      self.command_id      = event_message[:command_id]
      self.correlation_id  = event_message[:correlation_id] || self.command_id
      self.causation_id    = self.command_id
      self.event_id        = self.class.name
      self.timestamp       = event_message[:timestamp]
      self.event_version   = 1
      self.meta_data       = event_message[:meta_data]

      self.instance_exec(event_message[:data], &self.class._builder)
      self.data            = attributes
    end

    def to_h
      {
        aggregate_id:    aggregate_id,
        command_id:      command_id,
        event_id:        event_id,
        timestamp:       timestamp,
        event_version:   event_version,
        correlation_id:  correlation_id,
        causation_id:    causation_id,
        meta_data:       meta_data,
        data:            attributes,
      }
    end
  end
end
