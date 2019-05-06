# frozen_string_literal: true

require 'event_sourced/utils/message_handler'

module EventSourced
  class AggregateRoot
    include EventSourced::MessageHandler

    attr_reader :id, :type, :event_sequence_number, :uncommitted_events

    def self.load(aggregate_id)
      events = event_repository.stream(aggregate_id)

      aggregate = new(
        id: events.first[:aggregate_id],
        event_sequence_number: events.last[:event_sequence_number]
      )

      events.each do |event|
        aggregate.apply(event, new_event: false)
      end

      return aggregate
    end

    def initialize(id:, event_sequence_number: 0)
      @id = id
      @type = self.class.name
      @event_sequence_number = event_sequence_number
      @uncommitted_events = []
    end

    def apply(event, new_event: true)
      return unless handles_event?(event)

      if new_event
        event.event_sequence_number = @event_sequence_number + 1
        event.aggregate_id          = @id
        event.aggregate_type        = @type
      end

      handle_message(event)

      @event_sequence_number = event.event_sequence_number
      @uncommitted_events << event if new_event
    end

    def apply_raw_event(raw_event, new_event: true)
      event = build_event(raw_event)

      return unless event

      apply(event, new_event)
    end

    def handles_event?(event)
      self.class.handles_message?(event)
    end

    private

    def build_event(raw_event)
      return nil unless raw_event

      EventSourced::Event::Factory.build(raw_event[:type], raw_event)
    end

    def event_repository
      @event_repository
    end
  end
end
