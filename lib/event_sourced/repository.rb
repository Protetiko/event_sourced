# frozen_string_literal: true

module EventSourced
  module Repository
    InvalidEvent = Class.new(StandardError)
    InvalidEventCollection = Class.new(StandardError)
    NotImplemented = Class.new(StandardError)
    AggregateNotFound = Class.new(StandardError)

    def append(record)
      raise NotImplemented
    end

    def append_many(records)
      raise NotImplemented
    end

    def aggregate(aggregate_id)
      raise NotImplemented
    end

    def stream(aggregate_id)
      raise NotImplemented
    end

    def drop!
      raise NotImplemented
    end
  end
end
