# frozen_string_literal: true

require 'json'
require 'event_sourced/models/aggregate_record'
require 'event_sourced/models/snapshot_record'

module EventSourced
  class Repository
    InvalidEvent            = Class.new(StandardError)
    InvalidEventCollection  = Class.new(StandardError)
    NotImplemented          = Class.new(StandardError)
    AggregateNotFound       = Class.new(StandardError)
    EventStoreNotConfigured = Class.new(StandardError)
    InvalidAggregateRoot    = Class.new(StandardError)

    attr_reader :aggregate_klass, :store

    def initialize(aggregate:, store:)
      @aggregate_klass = aggregate
      @store           = store

      @aggregate_klass.repository = self
    end

    def create_aggregate(attributes)
      attributes[:created_at] = current_timestamp
      attributes[:type] = @aggregate_klass.to_s

      attributes = Validators::AggregateRecord.validate!(attributes)

      store.create_aggregate(attributes)

      return Models::AggregateRecord.new(attributes)
    end

    def read_aggregate(aggregate_id)
      return nil unless aggregate_id

      aggregate = store.read_aggregate(aggregate_id)

      return Models::AggregateRecord.new(aggregate)
    end

    def save_snapshot(aggregate_root)
      raise InvalidAggregateRoot unless aggregate_root.is_a?(AggregateRoot)

      snapshot = Models::Snapshot.new

      snapshot.aggregate_id = aggregate_root.id
      snapshot.type         = aggregate_root.type
      snapshot.created_at   = current_timestamp
      snapshot.data         = Base64.encode64(Marshal.dump(aggregate_root))

      result = store.save_snapshot(snapshot.to_h)
      store.update_aggregate(aggregate_root.id, last_snapshot_id: result[:id])
    end

    def read_snapshot(aggregate_id)
      return nil unless aggregate_id

      return Marshal.load(Base64.decode64(store.read_aggregate(aggregate_id)[:data]))
    end

    def append_command(command)
      store.append_command(command)
    end

    def append_event(event)
      store.append_event(event)
    end

    def append_events(events)
      store.append_events(events)
    end

    def aggregate(aggregate_id)
      aggregate = @aggregate_klass.new(self)
      aggregate.load_from_events(stream(aggregate_id))
    end

    def last_event(aggregate_id)
      event = store.last_event(aggregate_id)
      return EventSourced::Event::Factory.build!(event[:type], event)
    end

    def raw_event_stream(aggregate_id, from: 0, to: nil)
      store.event_stream(aggregate_id, from: from, to: to)
    end

    def event_stream(aggregate_id, from: 0, to: nil)
      events = raw_event_stream(aggregate_id, from: from, to: to)&.map do |record|
        EventSourced::Event::Factory.build!(record[:type], record)
      end

      return events || []
    end

    def drop_all!
      # +++ drop all aggregates and snapshots and commands +++
      store.destroy_all!
    end

    def drop_aggregate!(aggregate_id)
      # +++ drop aggregate from aggregate_store, snapshot_store and commands +++
      store.destroy_aggregate!(aggregate_id)
    end

    private

    def current_timestamp
      Time.now.utc.round(3)
    end

    def store
      @store || raise(EventStoreNotConfigured)
    end
  end

  # module RepoSetup
  #   module ClassMethods
  #     def repository
  #       @repository ||= Repository.new(aggregate: self, store: @event_store)
  #     end

  #     attr_accessor :event_store
  #   end

  #   def self.included(base)
  #     base.extend ClassMethods
  #   end

  #   def repository
  #     self.class.repository
  #   end
  # end
end
