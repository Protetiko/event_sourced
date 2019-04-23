# frozen_string_literal: true

require 'event_sourced/utils/message_handler'

module EventSourced
  class AggregateRoot
    include EventSourced::MessageHandler

    def initialize(repository)
      @event_repository = repository
    end

    def load(aggregate_id)
      load_from_events(event_repository.stream(aggregate_id))
    end

    def load_from_events(events)
      apply_events(events)
      return self
    end

    def apply_raw_event(raw_event)
      event = build_event_object(raw_event)

      return unless event

      handle_message(event)
    end

    def apply_event(event)
      return unless handles_event?(event)

      handle_message(event)
    end

    def apply_events(events)
      events.each do |event|
        apply_event(event)
      end
    end

    def build_event_object(raw_event)
      return nil unless raw_event

      EventSourced::Event::Factory.build(raw_event[:type], raw_event)
    end

    def handles_event?(event)
      self.class.handles_message?(event)
    end

    private

    def event_repository
      @event_repository
    end
  end
end
