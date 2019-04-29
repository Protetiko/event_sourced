require 'event_sourced/event_stores/mongo_event_store'

task :create_index do
  EventSourced::EventStores::MongoEventStore::Support.create_indexes
end
