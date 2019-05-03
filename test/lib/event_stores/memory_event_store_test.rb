# frozen_string_literal: true

require 'test_helper'

class MemoryEventStoreTest < EventStoreTest
  def event_store
    @event_store ||= EventSourced::EventStores::MemoryEventStore.new(
      aggregate_name: 'Company'
    )
  end
end
