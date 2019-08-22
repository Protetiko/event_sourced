# frozen_string_literal: true

require 'awesome_print'

AwesomePrint.defaults = {
  ruby19_syntax: true,
}

require 'event_sourced'

require_relative '../_common/commands.rb'
require_relative '../_common/events.rb'
require_relative '../_common/inventory_command_handler.rb'
require_relative '../_common/inventory_item.rb'
require_relative '../_common/messages.rb'
require_relative '../_common/inventory_count_projection.rb'
require_relative '../_common/item_description_projection.rb'

def run_examples(example_description:, repository:)
  puts "\n#### Running examples for: #{example_description}".purple

  #### TEST COMMAND HANDLER
  command_handler = InventoryCommandHandler.new(InventoryItem)

  command_handler.handle(CreateInventoryItem.new(CREATE_ITEM_COMMAND_MESSAGE))
  10.times { command_handler.handle(WithdrawInventoryItem.new(WITHDRAW_ITEM_COMMAND_MESSAGE)) }
  command_handler.handle(RestockInventoryItem.new(RESTOCK_ITEM_COMMAND_MESSAGE))
  command_handler.handle(SetItemDescription.new(SET_ITEM_DESCRIPTION_COMMAND_MESSAGE))
  command_handler.handle(WithdrawInventoryItem.new(WITHDRAW_ITEM_COMMAND_MESSAGE.merge(data: { count: 230 })))

  #### TEST USING AGGREGATE DIRECTLY
  item = InventoryItem.load(AGGREGATE_ID)
  item.apply InventoryItemRestocked.new(INVENTORY_ITEM_RESTOCKED)
  item.apply InventoryItemWithdrawn.new(INVENTORY_ITEM_WITHDRAWN)
  item.apply InventoryItemWithdrawn.new(INVENTORY_ITEM_WITHDRAWN)
  item.save
  # puts "\n## Should dump all commands:".white
  # command_repository.dump
  # puts "\n## Should dump all events:".white
  # event_repository.dump

  puts "\n## Aggregate record::".white
  ap repository.read_aggregate(AGGREGATE_ID).to_h
  puts "\n## Aggregate root:".white
  ap InventoryItem.load(AGGREGATE_ID).to_h

  puts "\n## Should find items from factory:".white
  puts " - Note, no :sequence_number because this is a 'raw' event.".blue
  puts "Command Factory: #{EventSourced::Command::Factory.for('CreateInventoryItem')}".green
  ap EventSourced::Event::Factory.build('InventoryItemCreated', INVENTORY_ITEM_CREATED).to_h

  puts "\n## Should return nils:".white
  ap EventSourced::Command::Factory.for('NibblePuddle')
  ap EventSourced::Event::Factory.build('NibblePuddle', INVENTORY_ITEM_CREATED)

  puts "\n## Should raise exception:".white
  EventSourced::Command::Factory.for!('NibblePuddle') rescue puts "Exception: NibblePuddle not found".red
  EventSourced::Event::Factory.build!('NibblePuddle', INVENTORY_ITEM_CREATED).to_h rescue puts "Exception: NibblePuddle not found".red

  puts "\n## Projections:".white
  proj = InventoryCountProjection.new
  obj = proj.apply(repository.event_stream(AGGREGATE_ID))
  puts "Inventory Count Projection: #{proj.entity.count}".green

  proj = ItemDescriptionProjection.new(repository.event_stream(AGGREGATE_ID))
  puts "Item Description Projection: #{proj.description}".green
end
