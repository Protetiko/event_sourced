# frozen_string_literal: true

require 'mongo'

module EventSourced
  module EventStores
    class MongoEventStore
      module Support
        def create_indexes
          collection.indexes.create_one(aggregate_id: 1)
          collection.indexes.create_one(aggregate_id: 1, timestamp: 1)
        end
      end

      def initialize(config = {})
        @database        = config[:database]   || 'event-store'
        @collection_name = config[:collection] || 'events'
      end

      def append(record)
        collection.insert_one(record.to_h)
      end

      def append_many(records)
        raise InvalidEventCollection unless records.is_a? Array
        collection.insert_many(records)
      end

      def read_stream(aggregate_id)
        map_records(collection.find(aggregate_id: aggregate_id).sort(timestamp: 1))
      end

      def all
        map_records(collection.find)
      end

      def destroy_all!
        collection.drop
      end

      def destroy_aggregate!(aggregate_id)
        return 0 unless aggregate_id
        result = collection.delete_many(aggregate_id: aggregate_id)
        return result.deleted_count
      end

      private

      def map_record(record)
        record.to_h.symbolize_keys!
      end

      def map_records(records)
        records.map do |r|
          map_record(r)
        end
      end

      def client
        @client ||= Mongo::Client.new(['127.0.0.1:27017'], database: @database)
      end

      def db
        @db ||= client.database
      end

      def collection
        @collection ||= client[@collection_name]
      end
    end
  end
end
