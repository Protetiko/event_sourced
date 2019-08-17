# frozen_string_literal: true

require 'event_sourced/utils/message_handler'

module EventSourced
  class AggregateRoot
    include EventSourced::MessageHandler

    attr_reader :id, :type, :sequence_number, :uncommitted_events, :created_at

    # class Snapshot
    #   def self.load
    #     factor.load('Order', data)
    #     return AggregateRoot
    #   end

    #   def initialize(aggregate_root)
    #     @aggregate_root = aggregate_root
    #   end

    #   def save
    #     @data = @aggregate_root.attributes.to_h

    #     repository.save_aggregate(self)
    #   end
    # end

    class << self
      def inherited(base)
        base.include EventSourced::RepoSetup
      end

      def create(aggregate_id)
        aggregate = new(id: aggregate_id)
        repository.create_aggregate(aggregate.to_h)
        return aggregate
      end

      def load(aggregate_id)
        events = repository.event_stream(aggregate_id)
        return nil unless events.present?

        aggregate = new(
          id: events.first.aggregate_id,
          sequence_number: events.last.sequence_number
        )

        events.each do |event|
          aggregate.apply(event, new_event: false)
        end

        return aggregate
      end

      def load_and_yield(aggregate_id)
        aggregate = load(aggregate_id)
        yield(aggregate)
        aggregate&.save
      end

      def create_and_yield(aggregate_id)
        aggregate = create(aggregate_id)
        yield(aggregate)
        aggregate.save
      end
    end

    def initialize(id:, sequence_number: 0)
      @id                    = id
      @type                  = self.class.name
      @sequence_number = sequence_number
      @uncommitted_events    = []
    end

    def apply(event, new_event: true)
      return unless handles_event?(event)

      if new_event
        event.sequence_number = @sequence_number + 1
        event.aggregate_id          = @id
        event.aggregate_type        = @type
      end

      handle_message(event)

      @sequence_number = event.sequence_number
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

    def save
      repository.append_events(@uncommitted_events)
      @uncommitted_events = []
    end

    def to_h
      {
        id: @id,
        type: @type,
        sequence_number: @sequence_number,
      }
    end

    private

    def build_event(raw_event)
      return nil unless raw_event

      EventSourced::Event::Factory.build(raw_event[:type], raw_event)
    end
  end
end
