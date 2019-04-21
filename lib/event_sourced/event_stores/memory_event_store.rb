# frozen_string_literal: true

module EventSourced
  module EventStores
    class MemoryEventStore
      def initialize(config = {})
        @store = {}
      end

      def append(record)
        aggregate_id = record.aggregate_id
        if store[aggregate_id]
          store[aggregate_id] << record.to_h
        else
          store[aggregate_id] = [record.to_h]
        end
      end

      def append_many(records)
        if records.is_a? Array
          records.each {|e| append(e) }
        else
          append(records)
        end
      end

      def read_stream(aggregate_id)
        store[aggregate_id]
      end

      def all
        store.to_a.map {|i, j| j }.flatten
      end

      def destroy_all!
        store = {}
      end

      def destroy_aggregate!(aggregate_id)
        store.delete(aggregate_id)
      end

      private

      def store
        @store ||= {}
      end
    end
  end
end
