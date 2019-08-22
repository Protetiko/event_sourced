# frozen_string_literal: true

require 'event_sourced'
require_relative '../_common/examples.rb'

Mongo::Logger.logger.level = Logger::WARN

# InventoryItem.event_store = EventSourced::EventStores::MongoEventStore.new(aggregate_name: 'Company')
# InventoryItem.repository.drop_all!

InventoryItemRepository = EventSourced::Repository.new(
  aggregate: InventoryItem,
  store: EventSourced::EventStores::MongoEventStore.new(
    aggregate_name: 'InventoryItem',
    client: Mongo::Client.new(['127.0.0.1:27017'], database: @database)
  )
)
InventoryItemRepository.drop_all!

run_examples(
  example_description: 'MongoDB Repository',
  repository: InventoryItemRepository
)
