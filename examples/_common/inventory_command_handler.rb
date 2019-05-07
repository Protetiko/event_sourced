# frozen_string_literal: true

require_relative 'inventory_item.rb'

class InventoryCommandHandler < EventSourced::CommandHandler

  #aggregate_root InventoryItem

  on CreateInventoryItem do |command|
    InventoryItem.create_and_yield(command.aggregate_id) do |item|
      item.apply InventoryItemCreated.new(command.to_h)
      item.apply InventoryItemRestocked.new(command.to_h) if command.count > 0
    end
  end

  on UpdateInventoryItem do |command|
    InventoryItem.load_and_yield(command.aggregate_id) do |item|
      item.apply InventoryItemUpdated.new(command.to_h)
    end
  end

  on RestockInventoryItem do |command|
    InventoryItem.load_and_yield(command.aggregate_id) do |item|
      item.apply InventoryItemRestocked.new(command.to_h)
    end
  end

  on WithdrawInventoryItem do |command|
    InventoryItem.load_and_yield(command.aggregate_id) do |item|
      item.apply InventoryItemWithdrawn.new(command.to_h)
    end
  end
end
