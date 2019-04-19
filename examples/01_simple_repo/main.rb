# frozen_string_literal: true

require 'awesome_print'
require 'event_sourced'
require_relative 'commands.rb'
require_relative 'events.rb'
require_relative 'inventory_command_handler.rb'
require_relative 'inventory_item.rb'

event_repository   = EventSourced::MemoryRepository.new
command_repository = EventSourced::MemoryRepository.new
command_handler    = InventoryCommandHandler.new(event_repository, command_repository)
item               = InventoryItem.new(event_repository)

base_command = {
  aggregate_id: "InventoryItem@4f6n3o2c3m43n2cjr2",
  meta_data: {
    user_id: "the-user-id",
  },
  version: 1,
}

aggregate_id = 'InventoryItem@4f6n3o2c3m43n2cjr2'

create_item_command_message = {
  aggregate_id: aggregate_id,
  command_type: "create_inventory_item",
  data: {
    description: "Fine wool blanket",
    count: 50,
    field_not_handled_by_service: "this will not appear in commands or events"
  },
  meta_data: {
    user_id: "the-user-id",
  },
  correlation_id: "the-correlation-id",
  version: 1,
}

restock_item_command_message = {
  aggregate_id: aggregate_id,
  command_type: "restock_inventory_item",
  data: {
    count: 200,
  },
  meta_data: {
    user_id: "the-user-id",
  },
  correlation_id: "the-correlation-id-2",
  version: 1,
}

withdraw_item_command_message = {
  aggregate_id: aggregate_id,
  command_type: "withdraw_inventory_item",
  data: {
    count: 2,
  },
  meta_data: {
    user_id: "the-user-id",
  },
  correlation_id: "the-correlation-id-2",
  version: 1,
}

command_handler.handle(CreateInventoryItem.new(create_item_command_message))
10.times { command_handler.handle(WithdrawInventoryItem.new(withdraw_item_command_message)) }
command_handler.handle(RestockInventoryItem.new(restock_item_command_message))
command_handler.handle(WithdrawInventoryItem.new(withdraw_item_command_message.merge({data:{count:240}})))

command_repository.dump
event_repository.dump

ap item.load(aggregate_id).to_h
