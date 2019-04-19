# frozen_string_literal: true

module EventSourced
  module AggregateRoot
    module ClassMethods
      def on(*events, &block)
        events.each do |event|
          event_map[event] ||= []
          event_map[event] << block
        end
      end

      def event_map
        @event_map ||= {}
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def initialize(repository)
      @event_repository = repository
    end

    def load(aggregate_id)
      handle_events(event_repository.stream(aggregate_id))
      self
    end

    def handle_event(event)
      if handles_event?(event)
        raise InvalidEvent.new unless event.valid?

        handlers = self.class.event_map[event.class]
        handlers.each {|handler| self.instance_exec(event, &handler) } if handlers
        #event_repository.append(event)
      end
    end

    def handle_events(events)
      events.each do |event|
        handle_event(event)
      end
    end

    private

    def handles_event?(event)
      self.class.event_map.keys.include? event.class
    end

    def event_repository
      @event_repository
    end
  end
end
