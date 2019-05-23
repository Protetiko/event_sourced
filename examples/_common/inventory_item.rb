# frozen_string_literal: true

require 'event_sourced/aggregate_root'

# The Inventory Item aggregate root

class InventoryItem < EventSourced::AggregateRoot
  attr_reader :id
  attr_reader :description
  attr_reader :created_at
  attr_reader :updated_at
  attr_reader :stock
  attr_reader :in_stock

  on InventoryItemCreated do |event, _|
    @id          = event.aggregate_id
    @description = event.description
    @created_at  = event.timestamp
    @stock       = 0

    calculate_availability
  end

  on InventoryItemUpdated do |event, _|
    @description = event.description
    @updated_at  = event.timestamp
  end

  on InventoryItemRestocked do |event, _|
    @stock += event.count

    calculate_availability
  end

  on InventoryItemWithdrawn do |event, _|
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
