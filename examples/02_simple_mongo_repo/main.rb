# frozen_string_literal: true

require 'semantic_logger'
require 'event_sourced'
require 'event_sourced/cache_backends/zache_backend'
require_relative '../_common/examples.rb'

Mongo::Logger.logger.level = Logger::WARN

EventSourced.configure do |config|
  config.logger        = SemanticLogger
  config.cache_backend = EventSourced::CacheBackends::Zache.new(client: Zache.new)
end

InventoryItemRepository = EventSourced::Repository.new(
  aggregate: InventoryItem,
  store: EventSourced::EventStores::MongoEventStore.new(
    aggregate_name: 'InventoryItem',
    client: Mongo::Client.new(['127.0.0.1:27017'], database: 'es_examples')
  )
)
InventoryItemRepository.drop_all!

run_examples(
  example_description: 'MongoDB Repository',
  repository: InventoryItemRepository
)
