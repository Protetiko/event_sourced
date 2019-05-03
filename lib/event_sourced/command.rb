# frozen_string_literal: true

require 'event_sourced/message'
require 'event_sourced/factory'

module EventSourced
  class Command
    Factory = Class.new(EventSourced::Factory)

    def self.inherited(base)
      Factory.register(base.name.split('::').last, base)
    end

    include EventSourced::Message

    attr_accessor :type
    attr_accessor :command_id
    attr_accessor :aggregate_id
    attr_accessor :aggregate_type
    attr_accessor :correlation_id
    attr_accessor :causation_id
    attr_accessor :data
    attr_accessor :meta_data
    attr_accessor :timestamp
    attr_accessor :version

    def initialize(command_message = {})
      command_message = Validators::CommandMessage.validate!(command_message)

      self.type            = self.class.name
      self.command_id      = command_message[:command_id] || UUID.generate
      self.aggregate_id    = command_message[:aggregate_id]
      self.aggregate_type  = command_message[:aggregate_type]
      self.correlation_id  = command_message[:correlation_id] || self.command_id
      self.causation_id    = command_message[:causation_id] || self.command_id

      timestamp = command_message[:timestamp] || DateTime.now.utc.round(3)
      timestamp = DateTime.parse(timestamp) if timestamp.is_a?(String)
      self.timestamp       = timestamp

      self.version         = command_message[:version] || 1
      self.meta_data       = command_message[:meta_data]

      # Set the internal `attributes` variable
      self.instance_exec(command_message[:data], &self.class._builder) if self.class._builder
      self.data            = attributes
    end

    def to_h
      h = {
        type:           type,
        command_id:     command_id,
        aggregate_id:   aggregate_id,
        aggregate_type: aggregate_type,
        timestamp:      timestamp,
        version:        version,
        correlation_id: correlation_id,
        causation_id:   causation_id,
      }

      h[:data]      = attributes if attributes.present?
      h[:meta_data] = meta_data  if meta_data.present?

      return h
    end
  end
end
