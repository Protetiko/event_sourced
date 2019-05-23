# frozen_string_literal: true

require 'test_helper'

event_store ||= EventSourced::EventStores::MongoEventStore.new(aggregate_name: 'item')
InventoryItem.event_store = event_store

class FullIntegrationTest < MiniTest::Test
  let(:event_store) { InventoryItem.event_store }

  let(:command_handler) {
    InventoryCommandHandler.new(InventoryItem.repository)
  }

  let(:aggregate_id) {
    EventSourced::UUID.generate
  }

  def teardown
    event_store.destroy_aggregate!(aggregate_id)
  end

  def test_it_handles_single_commands
    command = CreateInventoryItem.new(CREATE_ITEM_COMMAND_MESSAGE.merge(aggregate_id: aggregate_id))

    command_handler.handle(command)

    command_stream = event_store.command_stream(aggregate_id)
    assert_equal 1, command_stream.size

    assert_equal command.to_h.sort, CreateInventoryItem.new(command_stream.last).to_h.sort
    assert_equal 'CreateInventoryItem', command_stream.last[:type]

    event_stream = event_store.event_stream(command.aggregate_id)
    assert_equal 2, event_stream.size
    assert_equal 'InventoryItemCreated', event_stream.first[:type]
    assert_equal 'InventoryItemRestocked', event_stream.last[:type]
  end

  def test_it_handles_multiple_commands
    command_handler.handle_commands(
      [
        CreateInventoryItem.new(CREATE_ITEM_COMMAND_MESSAGE.merge(aggregate_id: aggregate_id)),
        UpdateInventoryItem.new(UPDATE_ITEM_COMMAND_MESSAGE.merge(aggregate_id: aggregate_id)),
        RestockInventoryItem.new(RESTOCK_ITEM_COMMAND_MESSAGE.merge(aggregate_id: aggregate_id))
      ]
    )

    command_stream = event_store.command_stream(aggregate_id)

    assert_equal 3, command_stream.size
    assert_equal 'CreateInventoryItem', command_stream.first[:type]
    assert_equal 'RestockInventoryItem', command_stream.last[:type]

    event_stream = event_store.event_stream(aggregate_id)
    assert_equal 4, event_stream.size
    assert_equal 'InventoryItemCreated', event_stream.first[:type]
    assert_equal 'InventoryItemRestocked', event_stream.last[:type]
  end
end
