# frozen_string_literal: true

require 'json'

module EventSourced
  class Repository
    InvalidEvent = Class.new(StandardError)
    InvalidEventCollection = Class.new(StandardError)
    NotImplemented = Class.new(StandardError)
    AggregateNotFound = Class.new(StandardError)
    EventStoreNotConfigured = Class.new(StandardError)

    def initialize(store: nil, **config)
      @store = store
    end

    def append(record)
      store.append(record)
    end

    def append_many(records)
      store.append_many(records)
    end

    def aggregate(aggregate_id)
      raise NotImplemented
    end

    def stream(aggregate_id)
      store.read_stream(aggregate_id)
    end

    def dump
      store.all.each do |record|
        puts JSON.pretty_generate(record.to_h).green
      end
    end

    def drop_all!
      store.destroy_all!
    end

    def drop_aggregate(aggregate_id)
      store.destroy_aggregate!(aggregate_id)
    end

    private

    def store
      @store || raise(EventStoreNotConfigured)
    end
  end
end
