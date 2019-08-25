# frozen_string_literal: true

require 'event_sourced/command'

class CreateItem < EventSourced::Command
  field :description
  field :count

  builder do |data|
    @description = data[:description]
    self.count       = data[:count]
  end
end

class SetDescription < EventSourced::Command
  field :description

  builder do |data|
    self.description = data[:description]
  end
end

class SetRetailPrice < EventSourced::Command
  field :price

  builder do |data|
    self.price = data[:price]
  end
end

class SetVendor < EventSourced::Command
  field :vendor_id
  field :vendor_name

  builder do |data|
    vendor = data[:vendor]
    self.vendor_id = vendor[:id]
    self.vendor_name = vendor[:name]
  end
end

class RestockInventory < EventSourced::Command
  field :count

  builder do |data|
    self.count = data[:count]
  end
end

class WithdrawInventory < EventSourced::Command
  field :count

  builder do |data|
    self.count = data[:count]
  end
end
