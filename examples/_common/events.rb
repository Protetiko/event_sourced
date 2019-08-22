# frozen_string_literal: true

require 'event_sourced/event'

class InventoryItemCreated < EventSourced::Event
  def to_s
    "#{self.class.name} - Created"
  end
end

class ItemDescriptionSet < EventSourced::Event
  field :description

  builder do |data|
    self.description = data[:description]
  end

  def to_s
    "#{self.class.name} - Set description to `#{self.description}`"
  end
end

class InventoryItemRestocked < EventSourced::Event
  field :count

  builder do |data|
    self.count = data[:count]
  end

  def to_s
    "#{self.class.name} - Increase stock to `#{self.count}`"
  end
end

class InventoryItemWithdrawn < EventSourced::Event
  field :count

  builder do |data|
    self.count = data[:count]
  end

  def to_s
    "#{self.class.name} - Decrease stock to `#{self.count}`"
  end
end
