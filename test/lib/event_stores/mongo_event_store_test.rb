# frozen_string_literal: true

require 'test_helper'

class MongoEventStoreTest < EventStoreTest
  def event_store
    @event_store ||= EventSourced::EventStores::MongoEventStore.new(
      aggregate_name: 'Company'
    )
  end

  def setup
    super

    #event_store.create_indexes
    #event_store.create_validators
  end
end
