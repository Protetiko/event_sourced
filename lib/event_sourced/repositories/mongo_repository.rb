# frozen_string_literal: true

require 'mongo'
require 'json'

module EventSourced
  class MongoRepository
    include EventSourced::Repository

    module Support
      def create_indexes
        result = collection.indexes.create_one({aggregate_id: 1})
        result = collection.indexes.create_one({aggregate_id: 1, timestamp: 1})
      end
    end

    def initialize(config)
      @database = config[:database] || 'event-store'
      @collection_name = config[:collection] || 'events'
    end

    def append(event)
      #raise InvalidEvent.new unless event.is_a? EventSourced::Message
      result = collection.insert_one(event.to_h)
    end

    def append_many(events)
      raise InvalidEventCollection.new unless event.is_a? Array
      result = collection.insert_many(events)
    end

    # def events(aggregate_id)
    #   return collection.find(aggregate_id) # order by timestamp
    # end

    def aggregate(aggregate_id)
      result = events(aggregate_id)
      result.each do |document|
      end
    end

    def raw_stream(aggregate_id)
      collection.find(aggregate_id: aggregate_id).map {|r| r.to_h.symbolize_keys! }
    end

    def stream(aggregate_id)
      collection.find(aggregate_id: aggregate_id).map {|r| r.to_h.symbolize_keys! }
    end

    def dump
      collection.find.each_with_index do |record, i|
        puts JSON.pretty_generate(record.to_h).green
      end
    end

    def drop!
      collection.drop
    end

    private

    def client
      @client ||= Mongo::Client.new([ '127.0.0.1:27017' ], :database => @database)
    end

    def db
      @db ||= client.database
    end

    def collection
      @collection ||= client[@collection_name]
    end
  end
end
