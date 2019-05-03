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

    def create_aggregate(attributes)
      attributes[:created_at] = current_timestamp
      attributes = Validators::AggregateRecord.validate!(attributes)

      event_store.create_aggregate(attributes)

      return AggregateRecord.new(attributes)
    end

    def read_aggregate(aggregate_id)
      return nil unless aggregate_id

      aggregate = event_store.read_aggregate(aggregate_id)

      return AggregateRecord.new(aggregate)
    end

    def save_snapshot(aggregate_root)
      raise InvalidAggregateRoot unless aggregate_root.kind_of?(AggregateRoot)

      snapshot = Validators::SnapshotRecord.validate!(aggregate_root.to_h)
      snapshot[:created_at] = current_timestamp

      result = event_store.save_snapshot(snapshot)
      event_store.update_aggregate(aggregate_id, { last_snapshot_id: result[:id] })
    end

    def append_command(command)
      event_store.append_command(command.to_h)
    end

    def append_event(event)
      event_store.append_event(event.to_h)
    end

    def append_events(events)
      event_store.append_events(events)
    end

    # This is only available for EventRepository
    def aggregate(aggregate_id)
      aggregate = @aggregate_klass.new(self)
      aggregate.load_from_events(stream(aggregate_id))
    end

    def raw_event_stream(aggregate_id)
      event_store.event_stream(aggregate_id)
    end

    def event_stream(aggregate_id)
      raw_event_stream(aggregate_id).map do |record|
        @factory.build!(record[:type], record)
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

    def current_timestamp
      Time.now.utc.round(3)
    end

    def event_store
      @event_store || raise(EventStoreNotConfigured)
    end
  end
end
