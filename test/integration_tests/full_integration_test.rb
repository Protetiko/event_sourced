# frozen_string_literal: true

require 'test_helper'

# event_store ||= EventSourced::EventStores::MongoEventStore.new(aggregate_name: 'item')
# Item.event_store = event_store

FullItemRepository = EventSourced::Repository.new(
  aggregate: Item,
  store: EventSourced::EventStores::MongoEventStore.new(
    aggregate_name: 'InventoryItem',
    client: Mongo::Client.new(['127.0.0.1:27017'], database: 'es_examples')
  )
)

class FullIntegrationTest < MiniTest::Test
  let(:repository) { FullItemRepository }
  let(:event_store) { FullItemRepository.store }

  let(:command_handler) {
    InventoryCommandHandler.new(Item)
  }

  let(:aggregate_id) {
    EventSourced::UUID.generate
  }

  def teardown
    event_store.destroy_aggregate!(aggregate_id)
  end

  def test_it_handles_single_commands
    command = CreateItem.new(CREATE_ITEM_COMMAND_MESSAGE.merge(aggregate_id: aggregate_id))

    command_handler.handle(command)

    command_stream = event_store.command_stream(aggregate_id)
    assert_equal 1, command_stream.size

    assert_equal command.to_h.sort, CreateItem.new(command_stream.last).to_h.sort
    assert_equal 'CreateItem', command_stream.last[:type]

    event_stream = event_store.event_stream(command.aggregate_id)
    assert_equal 2, event_stream.size
    assert_equal 'ItemCreated', event_stream.first[:type]
    assert_equal 'InventoryRestocked', event_stream.last[:type]
  end

  def test_it_handles_multiple_commands
    command_handler.handle_commands(
      [
        CreateItem.new(CREATE_ITEM_COMMAND_MESSAGE.merge(aggregate_id: aggregate_id)),
        SetDescription.new(SET_ITEM_DESCRIPTION_COMMAND_MESSAGE.merge(aggregate_id: aggregate_id)),
        RestockInventory.new(RESTOCK_ITEM_COMMAND_MESSAGE.merge(aggregate_id: aggregate_id))
      ]
    )

    command_stream = event_store.command_stream(aggregate_id)

    assert_equal 3, command_stream.size
    assert_equal 'CreateItem', command_stream.first[:type]
    assert_equal 'RestockInventory', command_stream.last[:type]

    event_stream = event_store.event_stream(aggregate_id)
    assert_equal 4, event_stream.size
    assert_equal 'ItemCreated', event_stream.first[:type]
    assert_equal 'InventoryRestocked', event_stream.last[:type]
  end
end
