# frozen_string_literal: true

require_relative '../inventory_item.rb'

class InventoryCommandHandler < EventSourced::CommandHandler

  #aggregate_root Item

  on CreateItem do |command|
    Item.create_and_yield(command.aggregate_id) do |item|
      c = command.to_h
      item.apply ItemCreated.new(c)
      item.apply DescriptionSet.new(c) if command.description
      item.apply InventoryRestocked.new(c) if command.count > 0
    end
  end

  on SetDescription do |command, item|
    item.apply DescriptionSet.new(command.to_h)
  end

  on SetRetailPrice do |command, item|
    item.apply RetailPriceSet.new(command.to_h)
  end

  on SetVendor do |command, item|
    item.apply VendorSet.new(command.to_h)
  end

  on RestockInventory do |command, item|
    item.apply InventoryRestocked.new(command.to_h)
  end

  on WithdrawInventory do |command, item|
    item.apply InventoryWithdrawn.new(command.to_h)
  end
end
