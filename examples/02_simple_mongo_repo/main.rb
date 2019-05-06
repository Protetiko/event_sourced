# frozen_string_literal: true

require 'awesome_print'
require 'event_sourced'
require_relative '../_common/commands.rb'
require_relative '../_common/events.rb'
require_relative '../_common/inventory_command_handler.rb'
require_relative '../_common/inventory_item.rb'
require_relative '../_common/messages.rb'
require_relative '../_common/examples.rb'

Mongo::Logger.logger.level = Logger::WARN

InventoryItem.event_store = EventSourced::EventStores::MongoEventStore.new(aggregate_name: 'Company')
InventoryItem.repository.drop_all!

run_examples(
  example_description: 'MongoDB Repository'
)
