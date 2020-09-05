# frozen_string_literal: true

module EventSourced
  class EventStream
    include Enumerable

    attr_accessor :aggregate_type, :aggregate_id

    def initialize(aggregate_type:, aggregate_id:)
      @aggregate_type = aggregate_type
      @aggregate_id   = aggregate_id
      @events         = []
    end

    def each(&block)
      yield(block)
    end
  end
end
