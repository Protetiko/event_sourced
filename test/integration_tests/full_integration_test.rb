# frozen_string_literal: true

require 'test_helper'

class FullIntegrationTest < MiniTest::Test
  let(:event_repository) {
    EventSourced::Repository.new(
      aggregate: InventoryItem,
      factory: EventSourced::Event::Factory,
      event_store: EventSourced::EventStores::MemoryEventStore.new
    )
  }

  let(:command_repository) {
    EventSourced::Repository.new(
      aggregate: InventoryItem,
      factory: EventSourced::Command::Factory,
      event_store: EventSourced::EventStores::MemoryEventStore.new
    )
  }

  let(:command_handler) { InventoryCommandHandler.new(event_repository, command_repository) }

  def setup
    command_repository.drop_all!
    event_repository.drop_all!
  end

  def test_it_handles_single_commands
    command = CreateInventoryItem.new(CREATE_ITEM_COMMAND_MESSAGE)
    command_handler.handle(command)
    command_stream = command_repository.stream(command.aggregate_id)
    event_stream = event_repository.stream(command.aggregate_id)

    assert_equal 1, command_stream.size
    assert_equal command.to_h.sort, command_stream.last.to_h.sort

    assert_equal 2, event_stream.size
    assert_equal InventoryItemCreated, event_stream.first.class
    assert_equal InventoryItemRestocked, event_stream.last.class
  end

  def test_it_handles_multiple_commands
    command_handler.handle_commands([
      CreateInventoryItem.new(CREATE_ITEM_COMMAND_MESSAGE),
      UpdateInventoryItem.new(UPDATE_ITEM_COMMAND_MESSAGE),
      RestockInventoryItem.new(RESTOCK_ITEM_COMMAND_MESSAGE)
    ])
    command_stream = command_repository.stream(CREATE_ITEM_COMMAND_MESSAGE[:aggregate_id])

    assert_equal 3, command_stream.size
    assert_equal CreateInventoryItem, command_stream.first.class
    assert_equal RestockInventoryItem, command_stream.last.class
  end
end
