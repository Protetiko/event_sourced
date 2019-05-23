# frozen_string_literal: true

require 'awesome_print'
require 'event_sourced'
require_relative '../_common/commands.rb'
require_relative '../_common/events.rb'
require_relative '../_common/inventory_command_handler.rb'
require_relative '../_common/inventory_item.rb'
require_relative '../_common/messages.rb'
require_relative '../_common/examples.rb'

InventoryItem.event_store = EventSourced::EventStores::MemoryEventStore.new

run_examples(
  example_description: 'Memory Repository'
)
