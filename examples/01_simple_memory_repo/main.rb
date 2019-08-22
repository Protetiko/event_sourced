# frozen_string_literal: true

require 'semantic_logger'
require 'zache'

require 'event_sourced/cache_backends/zache_backend'

require_relative '../_common/examples.rb'

EventSourced.configure do |config|
  config.logger        = SemanticLogger
  config.cache_backend = EventSourced::CacheBackends::Zache.new(client: Zache.new)
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
