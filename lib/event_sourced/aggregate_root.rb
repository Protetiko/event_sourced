# frozen_string_literal: true

module EventSourced
  module AggregateRoot
    module ClassMethods
      def on(*events, &block)
        events.each do |event|
          event_map[event.name] ||= []
          event_map[event.name] << block
          event_table[event.name] = event
        end
      end

      def event_map
        @event_map ||= {}
      end

      def event_table
        @event_table ||= {}
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

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

    def apply_raw_event(event)
      event = build_event_object(event_class: event[:type], data: event)

      return unless event

      handlers = self.class.event_map[event.type]
      handlers.each {|handler| self.instance_exec(event, &handler) } if handlers
    end

    def apply_event(event)
      return unless handles_event?(event.type)

      handlers = self.class.event_map[event.type]
      handlers.each {|handler| self.instance_exec(event, &handler) } if handlers
    end

    def apply_events(events)
      events.each do |event|
        apply_event(event)
      end
    end

    def build_event_object(event_class: nil, data: nil, **_params)
      return nil unless event_class
      return nil unless data

      self.class.event_table[event_class]&.new(data)
    end

    private

    def handles_event?(event)
      self.class.event_map.keys.include? event
    end

    def event_repository
      @event_repository
    end
  end
end
