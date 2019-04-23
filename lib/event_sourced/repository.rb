# frozen_string_literal: true

require 'json'

module EventSourced
  class Repository
    InvalidEvent = Class.new(StandardError)
    InvalidEventCollection = Class.new(StandardError)
    NotImplemented = Class.new(StandardError)
    AggregateNotFound = Class.new(StandardError)
    EventStoreNotConfigured = Class.new(StandardError)

    def initialize(aggregate:, event_store:, factory:, **_config)
      @aggregate_klass = aggregate
      @factory         = factory
      @event_store     = event_store
    end

    def append(record)
      event_store.append(record)
    end

    def append_many(records)
      event_store.append_many(records)
    end

    # This is only available for EventRepository
    def aggregate(aggregate_id)
      aggregate = @aggregate_klass.new(self)
      aggregate.load_from_events(stream(aggregate_id))
    end

    def raw_stream(aggregate_id)
      event_store.read_stream(aggregate_id)
    end

    def stream(aggregate_id)
      raw_stream(aggregate_id).map do |record|
        @factory.build(record[:type], record)
      end
    end

    def dump
      event_store.all.each do |record|
        ap record.to_json
        #puts JSON.pretty_generate(record).blue
      end
    end

    def drop_all!
      # +++ drop all aggregates and snapshots and commands +++
      event_store.destroy_all!
    end

    def drop_aggregate!(aggregate_id)
      # +++ drop aggregate from aggregate_store, snapshot_store and commands +++
      event_store.destroy_aggregate!(aggregate_id)
    end

    private

    def event_store
      @event_store || raise(EventStoreNotConfigured)
    end
  end
end
