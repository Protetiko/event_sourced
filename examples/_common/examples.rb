# frozen_string_literal: true

def run_examples(example_description:)
  puts "\n#### Running examples for: #{example_description}".purple

  command_handler = InventoryCommandHandler.new(InventoryItem.repository)

  command_handler.handle(CreateInventoryItem.new(CREATE_ITEM_COMMAND_MESSAGE))
  10.times { command_handler.handle(WithdrawInventoryItem.new(WITHDRAW_ITEM_COMMAND_MESSAGE)) }
  command_handler.handle(RestockInventoryItem.new(RESTOCK_ITEM_COMMAND_MESSAGE))
  command_handler.handle(UpdateInventoryItem.new(UPDATE_ITEM_COMMAND_MESSAGE))
  command_handler.handle(WithdrawInventoryItem.new(WITHDRAW_ITEM_COMMAND_MESSAGE.merge({ data: { count: 230 } })))

  # puts "\n## Should dump all commands:".white
  # command_repository.dump
  # puts "\n## Should dump all events:".white
  # event_repository.dump

  puts "\n## Should produce the same result:".white
  ap InventoryItem.load(AGGREGATE_ID).to_h
  ap InventoryItem.repository.read_aggregate(AGGREGATE_ID).to_h

  puts "\n## Should find items from factory:".white
  puts " - Note, no :aggregate_type or :event_sequence_number because this is a 'raw' event.".green
  ap EventSourced::Command::Factory.for('CreateInventoryItem')
  ap EventSourced::Event::Factory.build('InventoryItemCreated', INVENTORY_ITEM_CREATED).to_h

  puts "\n## Should return nils:".white
  ap EventSourced::Command::Factory.for('NibblePuddle')
  ap EventSourced::Event::Factory.build('NibblePuddle', INVENTORY_ITEM_CREATED)

  puts "\n## Should raise exception:".white
  EventSourced::Command::Factory.for!('NibblePuddle') rescue ap "Exception: NibblePuddle not found"
  EventSourced::Event::Factory.build!('NibblePuddle', INVENTORY_ITEM_CREATED).to_h rescue ap "Exception: NibblePuddle not found"
end
