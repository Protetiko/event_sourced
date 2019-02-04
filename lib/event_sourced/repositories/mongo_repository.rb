# frozen_string_literal: true

require 'mongo'
require 'json'
require 'event_sourced/repository'
require_relative 'event.rb'

class MongoRepository
  module Support
    def create_indexes
      result = collection.indexes.create_one({aggregate_id: 1})
      result = collection.indexes.create_one({aggregate_id: 1, timestamp: 1})
    end
  end

  include EventSourced::Repository

  def append(event)
    raise InvalidEvent.new unless event.is_a? Event
    result = collection.insert_one(event.to_h)
  end

  def append_many(events)
    raise InvalidEvent.new unless event.is_a? Array
    result = collection.insert_many(events)
  end

  def events(aggregate_id)
    return collection.find(aggregate_id) # order by timestamp
  end

  def aggregate(aggregate_id)
    result = events(aggregate_id)
    result.each do |document|
    end
  end

  private

  def client
    @client ||= Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'order-event-store')
  end

  def db
    @db ||= client.database
  end

  def collection
    @collection ||= client['events']
  end
end
