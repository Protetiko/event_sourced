# frozen_string_literal: true

require 'awesome_print'
require 'event_sourced'
require_relative '../_common/commands.rb'
require_relative '../_common/events.rb'
require_relative '../_common/inventory_command_handler.rb'
require_relative '../_common/inventory_item.rb'
require_relative '../_common/messages.rb'

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
command_handler    = InventoryCommandHandler.new(event_repository, command_repository)

event_repository.drop_all!
command_repository.drop_all!

command_handler.handle(CreateInventoryItem.new(CREATE_ITEM_COMMAND_MESSAGE))
10.times { command_handler.handle(WithdrawInventoryItem.new(WITHDRAW_ITEM_COMMAND_MESSAGE)) }
command_handler.handle(RestockInventoryItem.new(RESTOCK_ITEM_COMMAND_MESSAGE))
command_handler.handle(UpdateInventoryItem.new(UPDATE_ITEM_COMMAND_MESSAGE))
command_handler.handle(WithdrawInventoryItem.new(WITHDRAW_ITEM_COMMAND_MESSAGE.merge({ data: { count: 230 } })))

# command_repository.dump
# event_repository.dump

item = InventoryItem.new(event_repository)
ap item.load(AGGREGATE_ID).to_h
ap event_repository.aggregate(AGGREGATE_ID).to_h

ap EventSourced::Command::Factory.for('CreateInventoryItem')
ap EventSourced::Event::Factory.build('InventoryItemCreated', INVENTORY_ITEM_CREATED).to_h
