# frozen_string_literal: true

require 'json'
require 'event_sourced/repository'
require_relative 'event.rb'

class DynamoRepository
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
    return collection.find(aggregate) # order by timestamp? version?
  end

  def aggregate(aggregate_id)
    result = events(aggregate_id)
    result.each do |document|
    end
  end

  private

  def client
    @client ||= Dynamoid::Client.new([ '127.0.0.1:27017' ], :database => 'order-event-store')
  end

  def db
    @db ||= client.database
  end

  def collection
    @collection ||= client['events']
  end
end
