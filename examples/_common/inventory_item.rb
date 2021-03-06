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

  def initialize(id:, sequence_number: 0)
    @stock    = 0
    @in_stock = false

    super(id: id, sequence_number: sequence_number)
  end

  on InventoryItemCreated do |event|
    @id          = event.aggregate_id
    @created_at  = event.timestamp
    @stock       = 0

    calculate_availability
  end

  on ItemDescriptionSet do |event|
    @description = event.description
    @updated_at  = event.timestamp
  end

  on InventoryItemRestocked do |event|
    @stock += event.count

    calculate_availability
  end

  on InventoryItemWithdrawn do |event|
    @stock -= event.count

    # reject if @stock - event.count < 0
    # publish low stock event on queues if under 10 in stock <--- This should not be the responsibility
    # for this service. Some other service should keep track of inventory item events and warn.

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
