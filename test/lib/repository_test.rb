# frozen_string_literal: true

require 'test_helper.rb'

class DummyItem < EventSourced::AggregateRoot
end

class RepositoryTest < MiniTest::Test
  include EventSourced::Examples

  let(:repository) {
    EventSourced::Repository.new(
      aggregate: DummyItem,
      store: EventSourced::EventStores::MemoryEventStore.new
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
    assert_equal 'DummyItem', aggregate.type
    assert aggregate.created_at

    aggregate = repository.read_aggregate(aggregate_id)
    assert_equal aggregate_id, aggregate.id
    assert_equal 'DummyItem', aggregate.type
    assert aggregate.created_at
  end

  # def test_snapshot_interface
  #   aggregate = DummyItem.new(id: aggregate_id)
  #   aggregate.save
  #   repository.save_snapshot(aggregate)
  # end
end
