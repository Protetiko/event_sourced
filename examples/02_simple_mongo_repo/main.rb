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

event_repository   = EventSourced::Repository.new(
  aggregate: InventoryItem,
  factory: EventSourced::Event::Factory,
  event_store: EventSourced::EventStores::MongoEventStore.new(collection: 'item-events')
)
command_repository = EventSourced::Repository.new(
  aggregate: InventoryItem,
  factory: EventSourced::Command::Factory,
  event_store: EventSourced::EventStores::MongoEventStore.new(collection: 'item-commands')
)

event_repository.drop_all!
command_repository.drop_all!

run_examples(command_repository, event_repository)
