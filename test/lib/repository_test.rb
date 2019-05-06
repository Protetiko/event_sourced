# frozen_string_literal: true

require 'test_helper.rb'

class RepositoryTest < MiniTest::Test
  let(:event_store) {
    EventSourced::EventStores::MemoryEventStore.new
  }
  let(:repository) {
    EventSourced::Repository.new(
      aggregate: InventoryItem,
      factory: EventSourced::Event::Factory,
      event_store: event_store
    )
  }

  def test_interface
    assert repository.respond_to? :create_aggregate
    assert repository.respond_to? :read_aggregate
    assert repository.respond_to? :save_snapshot
    assert repository.respond_to? :append_command
    assert repository.respond_to? :append_event
    assert repository.respond_to? :append_events
    assert repository.respond_to? :aggregate
    assert repository.respond_to? :raw_event_stream
    assert repository.respond_to? :event_stream
    assert repository.respond_to? :dump
    assert repository.respond_to? :drop_all!
    assert repository.respond_to? :drop_aggregate!
  end
end
