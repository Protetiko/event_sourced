# frozen_string_literal: true

require 'semantic_logger'

require 'event_sourced/cache_backends/zache'
require 'event_sourced/cache_backends/memory'
require 'event_sourced/cache_backends/redis'

require_relative '../_common/examples.rb'

EventSourced.configure do |config|
  config.logger        = SemanticLogger
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

run_examples(
  example_description: 'Memory Repository',
  repository: InventoryItemRepository
)
