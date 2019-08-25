# frozen_string_literal: true

require 'semantic_logger'
require 'event_sourced'
require 'event_sourced/cache_backends/zache'
require_relative '../_common/examples.rb'

Mongo::Logger.logger = SemanticLogger[Mongo]
Mongo::Logger.logger.level = Logger::INFO

SemanticLogger.add_appender(io: STDOUT, formatter: :color)
SemanticLogger.default_level = :debug

EventSourced.configure do |config|
  config.logger        = SemanticLogger['EventSourced']
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

EventSourced::Logger.info("Starting Example 2 with MongoDB Event Store")

run_examples(
  example_description: 'MongoDB Event Store',
  repository: InventoryItemRepository
)
