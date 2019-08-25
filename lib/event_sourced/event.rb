# frozen_string_literal: true

require 'event_sourced/message'
require 'event_sourced/factory'

module EventSourced
  class Event
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
    attr_accessor :sequence_number

    def initialize(message = {})
      message = Validators::EventMessage.validate!(message)

      @type            = self.class.name
      @aggregate_id    = message[:aggregate_id]
      @aggregate_type  = message[:aggregate_type]
      @command_id      = message[:command_id]
      @correlation_id  = message[:correlation_id] || @command_id
      @causation_id    = @command_id
      @sequence_number = message[:sequence_number]

      timestamp = message[:timestamp] || DateTime.now.utc.round(3)
      timestamp = DateTime.parse(timestamp) if timestamp.is_a?(String)
      @timestamp = timestamp

      # Set the internal `attributes` variable
      if message[:data]
        self.instance_exec(message[:data].symbolize_keys, &self.class._builder) if self.class._builder
      end

      @data = attributes
      @meta_data = message[:meta_data]
    end

    def to_h
      h = {
        type:            type,
        aggregate_id:    aggregate_id,
        aggregate_type:  aggregate_type,
        command_id:      command_id,
        correlation_id:  correlation_id,
        causation_id:    causation_id,
        timestamp:       timestamp,
        sequence_number: sequence_number,
      }

      h[:data]      = attributes if attributes.present?
      h[:meta_data] = meta_data  if meta_data.present?

      return h
    end
  end
end
