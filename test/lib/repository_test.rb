# frozen_string_literal: true

require 'test_helper.rb'

class RepositoryTest < MiniTest::Test
  let(:event_store) {
    EventSourced::EventStores::MemoryEventStore.new
  }

  let(:repository) {
    EventSourced::Repository.new(
      aggregate: InventoryItem,
      store: event_store
    )
  }

  let(:aggregate_id) {
    EventSourced::UUID.generate
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

  def test_aggregate_interface
    aggregate_attributes = {
      id:   aggregate_id
    }
    aggregate = repository.create_aggregate(aggregate_attributes)

    assert_instance_of EventSourced::Models::AggregateRecord, aggregate
    assert_equal aggregate_id, aggregate.id
    assert_equal 'InventoryItem', aggregate.type
    assert aggregate.created_at

    aggregate = repository.read_aggregate(aggregate_id)
    assert_equal aggregate_id, aggregate.id
    assert_equal 'InventoryItem', aggregate.type
    assert aggregate.created_at
  end

  # def test_snapshot_interface


  #   repository.save_snapshot(snapshot_attributes)
  # end
end
