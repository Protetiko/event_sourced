# frozen_string_literal: true

require 'test_helper'

class FullIntegrationTest < MiniTest::Test
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

  let(:command_handler) { InventoryCommandHandler.new(repository) }

  def setup
    repository.drop_all!
  end

  def test_it_handles_single_commands
    command = CreateInventoryItem.new(CREATE_ITEM_COMMAND_MESSAGE)

    command_handler.handle(command)
    command_stream = event_store.command_stream(command.aggregate_id)
    event_stream = event_store.event_stream(command.aggregate_id)

    assert_equal 1, command_stream.size
    assert_equal command.to_h.merge(id: command_stream.last[:id]).sort, command_stream.last.sort
    assert_equal 'CreateInventoryItem', command_stream.last[:type]

    assert_equal 2, event_stream.size
    assert_equal 'InventoryItemRestocked', event_stream.first[:type]
    assert_equal 'InventoryItemCreated', event_stream.last[:type]
  end

  def test_it_handles_multiple_commands
    command_handler.handle_commands([
      CreateInventoryItem.new(CREATE_ITEM_COMMAND_MESSAGE),
      UpdateInventoryItem.new(UPDATE_ITEM_COMMAND_MESSAGE),
      RestockInventoryItem.new(RESTOCK_ITEM_COMMAND_MESSAGE)
    ])
    aggregate_id = CREATE_ITEM_COMMAND_MESSAGE[:aggregate_id]
    command_stream = event_store.command_stream(aggregate_id)

    assert_equal 3, command_stream.size
    assert_equal 'RestockInventoryItem', command_stream.first[:type]
    assert_equal 'CreateInventoryItem', command_stream.last[:type]

    event_stream = event_store.event_stream(aggregate_id)
    assert_equal 4, event_stream.size
    assert_equal 'InventoryItemRestocked', event_stream.first[:type]
    assert_equal 'InventoryItemCreated', event_stream.last[:type]
  end
end
