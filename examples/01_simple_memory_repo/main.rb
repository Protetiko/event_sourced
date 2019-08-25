# frozen_string_literal: true

require 'semantic_logger'

require 'event_sourced/cache_backends/zache'
require 'event_sourced/cache_backends/memory'
require 'event_sourced/cache_backends/redis'

require_relative '../_common/examples.rb'

SemanticLogger.add_appender(io: STDOUT, formatter: :color)
SemanticLogger.default_level = :debug

EventSourced.configure do |config|
  config.logger        = SemanticLogger['EventSourced']
  config.cache_backend = EventSourced::CacheBackends::Redis.new(
    client: Redis.new
  )
  #config.cache_backend = EventSourced::CacheBackends::MemoryCache.new
  #config.cache_backend = EventSourced::CacheBackends::Zache.new
end

InventoryItemRepository = EventSourced::Repository.new(
  aggregate: InventoryItem,
  store: EventSourced::EventStores::MemoryEventStore.new
)

InventoryItemRepository.drop_all!

EventSourced::Logger.info("Starting Example 1 with Memory Repository")

run_examples(
  example_description: 'Memory Repository',
  repository: InventoryItemRepository
)
