# frozen_string_literal: true

require 'event_sourced/aggregate_root'

require_relative 'inventory_item/commands.rb'
require_relative 'inventory_item/events.rb'
require_relative 'inventory_item/inventory_command_handler.rb'
require_relative 'inventory_item/messages.rb'

class Item < EventSourced::AggregateRoot

  attr_reader :id
  attr_reader :description
  attr_reader :created_at
  attr_reader :updated_at
  attr_reader :stock
  attr_reader :in_stock
  attr_reader :vendor
  attr_reader :price

  # before do |event|
  #   @updated_at  = event.timestamp
  # end

  on ItemCreated do |event|
    @id          = event.aggregate_id
    @created_at  = event.timestamp
    @stock       = 0

    calculate_availability
  end

  on DescriptionSet do |event|
    @description = event.description
    @updated_at  = event.timestamp
  end

  on RetailPriceSet do |event|
    @price = event.price
  end

  on VendorSet do |event|
    @vendor = {
      id:   event.vendor_id,
      name: event.vendor_name,
    }
  end

  on InventoryRestocked do |event|
    @stock += event.count

    calculate_availability
  end

  on InventoryWithdrawn do |event|
    @stock -= event.count

    # reject if @stock - event.count < 0
    # publish low stock event on queues if under 10 in stock <--- This should not be the responsibility for this service. Some other service should keep track of inventory item events and warn.

    calculate_availability
  end

  def calculate_availability
    @in_stock = @stock > 0
  end

  def to_h
    {
      id:          id,
      description: description,
      stock:       stock,
      in_stock:    in_stock,
      created_at:  created_at,
      updated_at:  updated_at,
    }
  end
end
