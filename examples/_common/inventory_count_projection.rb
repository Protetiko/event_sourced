# frozen_string_literal: true

require 'event_sourced/projection'

class InventoryCountProjection < EventSourced::Projection
  attr_reader :entity

  CountEntity = Struct.new(:id, :count)

  def initialize
    @entity = CountEntity.new
  end

  on InventoryItemCreated do |event|
    entity.id    = event.aggregate_id
    entity.count = 0
  end

  on InventoryItemRestocked do |event|
    entity.count += event.count
  end

  on InventoryItemWithdrawn do |event|
    entity.count -= event.count
  end
end
