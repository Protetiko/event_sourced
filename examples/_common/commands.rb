# frozen_string_literal: true

require 'event_sourced/command'

class CreateInventoryItem < EventSourced::Command
  field :description
  field :count

  builder do |data|
    self.description = data[:description]
    self.count       = data[:count]
  end
end

class SetItemDescription < EventSourced::Command
  field :description

  builder do |data|
    self.description = data[:description]
  end
end

class RestockInventoryItem < EventSourced::Command
  field :count

  builder do |data|
    self.count = data[:count]
  end
end

class WithdrawInventoryItem < EventSourced::Command
  field :count

  builder do |data|
    self.count = data[:count]
  end
end
