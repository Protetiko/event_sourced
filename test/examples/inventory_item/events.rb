# frozen_string_literal: true

require 'event_sourced/event'

class ItemCreated < EventSourced::Event
  builder do |data|

  end
end

class DescriptionSet < EventSourced::Event
  field :description

  builder do |data|
    self.description = data[:description]
  end
end

class VendorSet < EventSourced::Event
  field :vendor_id
  field :vendor_name

  builder do |data|
    self.vendor_id   = data[:vendor_id]
    self.vendor_name = data[:vendor_name]
  end
end
class RetailPriceSet < EventSourced::Event
  field :price

  builder do |data|
    self.price = data[:price]
    self.price_updated_at = data[:timestamp]
  end
end

class InventoryRestocked < EventSourced::Event
  field :count

  builder do |data|
    self.count = data[:count]
  end
end

class InventoryWithdrawn < EventSourced::Event
  field :count

  builder do |data|
    self.count = data[:count]
  end
end
