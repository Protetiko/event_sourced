# frozen_string_literal: true

module EventSourced
  module EventStores
    class MongoEventStore
      module Support
        extend self

        def create_indexes(collections)
          collections.events.indexes.create_one(aggregate_id: 1)
          collections.events.indexes.create_one(aggregate_id: 1, timestamp: 1)

          collections.commands.indexes.create_one(aggregate_id: 1)
          collections.commands.indexes.create_one(aggregate_id: 1, timestamp: 1)

          collections.aggregates.indexes.create_one(aggregate_id: 1)

          collections.snapshots.indexes.create_one(aggregate_id: 1, created_at: -1)
        end

        def create_validators(db, collection_names)
          set_aggregate_validation(db, collection_names.aggregates)
          set_command_validation(db, collection_names.commands)
          set_event_validation(db, collection_names.events)
          set_snapshot_validation(db, collection_names.snapshots)
        end

        private

        def set_aggregate_validation(db, collection_name)
          db.command(
            'collMod' => collection_name,
            'validator' => {
              '$or' => [
                { 'type'             => { '$type' => 'string' } },
                { 'last_snapshot_id' => { '$type' => 'objectId' } },
                { 'created_at'       => { '$type' => 'date' } },
              ]
            }
          )
        end

        def set_event_validation(db, collection_name); end

        def set_command_validation(db, collection_name); end

        def set_snapshot_validation(db, collection_name)
          db.command(
            'collMod' => collection_name,
            'validator' => {
              '$or' => [
                { 'aggregate_id'    => { '$type' => 'string' } },
                { 'aggregate_type'  => { '$type' => 'string' } },
                { 'sequence_number' => { '$type' => 'int' } },
                { 'data'            => { '$type' => 'object' } },
                { 'create_at'       => { '$type' => 'date' } },
              ]
            }
          )
        end
      end
    end
  end
end
