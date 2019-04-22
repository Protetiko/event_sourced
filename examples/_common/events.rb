# frozen_string_literal: true

require 'event_sourced/event'

class InventoryItemCreated < EventSourced::Event
  field :description

  builder do |data|
    self.description = data[:description]
  end
end

class InventoryItemUpdated < EventSourced::Event
  field :description

  builder do |data|
    self.description = data[:description]
  end
end

class InventoryItemRestocked < EventSourced::Event
  field :count

  builder do |data|
    self.count = data[:count]
  end
end

class InventoryItemWithdrawn < EventSourced::Event
  field :count

  builder do |data|
    self.count = data[:count]
  end
end
