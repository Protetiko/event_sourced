# frozen_string_literal: true

require_relative 'inventory_item.rb'

class InventoryCommandHandler
  include EventSourced::CommandHandler

  #aggregate_root InventoryItem

  on CreateInventoryItem do |command|
    apply InventoryItemCreated.new(command.to_h)
    apply InventoryItemRestocked.new(command.to_h) if command.count > 0
  end

  on UpdateInventoryItem do |command|
    apply InventoryItemUpdated.new(command.to_h)
  end

  on RestockInventoryItem do |command|
    apply InventoryItemRestocked.new(command.to_h)
  end

  on WithdrawInventoryItem do |command|
    apply InventoryItemWithdrawn.new(command.to_h)
  end
end
