# frozen_string_literal: true

require 'event_sourced/projection'

class ItemDescriptionProjection < EventSourced::Projection
  attr_reader :id
  attr_reader :description

  def initialize(events)
    apply(events)
  end

  on InventoryItemCreated do |event|
    @id          = event.aggregate_id
    @description = ''
  end

  on ItemDescriptionSet do |event|
    @description = event.description
  end
end
