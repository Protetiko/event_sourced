# frozen_string_literal: true

require 'test_helper'

module EventSourced
  module Examples
    def seed_db
      assert(false, "aggregate_id must be defined to use :seed_db") unless aggregate_id
      assert(false, "event_store must be defined to use :seed_db") unless event_store

      InventoryItem.event_store = event_store
      command_handler = InventoryCommandHandler.new(InventoryItem.repository)

      command_handler.handle(CreateInventoryItem.new(CREATE_ITEM_COMMAND_MESSAGE.merge(aggregate_id: aggregate_id)))
      10.times do
        command_handler.handle(WithdrawInventoryItem.new(WITHDRAW_ITEM_COMMAND_MESSAGE.merge(aggregate_id: aggregate_id)))
      end
      command_handler.handle(RestockInventoryItem.new(RESTOCK_ITEM_COMMAND_MESSAGE.merge(aggregate_id: aggregate_id)))
      command_handler.handle(UpdateInventoryItem.new(UPDATE_ITEM_COMMAND_MESSAGE.merge(aggregate_id: aggregate_id)))
      command_handler.handle(WithdrawInventoryItem.new(WITHDRAW_ITEM_COMMAND_MESSAGE.merge(aggregate_id: aggregate_id, data: { count: 230 })))
    end
  end
end
