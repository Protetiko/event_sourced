module EventSourced
  module Repository
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

    def events(aggregate_id)
      raise NotImplemented
    end
  end
end
