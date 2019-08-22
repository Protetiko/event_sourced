# frozen_string_literal: true

require 'mongo'
require 'event_sourced/event_stores/event_store'
require 'event_sourced/utils/extensions/string'

module EventSourced
  module EventStores
    class MongoEventStore < EventStore
      def initialize(config = {})
        @aggregate_name = config[:aggregate_name].snakecase || nil
        @client = config[:client]
      end

      def create_aggregate(attributes)
        raise(CreateAggregateRecordFailed, 'Aggregate update attributes must be a Hash') unless attributes.is_a?(Hash)

        attributes = Hash[attributes]
        attributes[:_id] = attributes.delete(:id) # MongoDB specific ID here

        begin
          aggregates_collection.insert_one(attributes)
        rescue Mongo::Error::OperationFailure => _e
          raise CreateAggregateRecordFailed, 'Failed to create Aggregate record: Duplicate ID.'
        rescue
          raise CreateAggregateRecordFailed, 'Failed to create Aggregate record: Unknown DB error.'
        end
      end

      def read_aggregate(aggregate_id)
        result = aggregates_collection.find(_id: aggregate_id)

        raise(AggregateRecordNotFound, "Aggregate with id #{aggregate_id} not found") if result.count.zero?

        aggregate = result.first.symbolize_keys
        aggregate[:id] = aggregate.delete(:_id).to_s
        return aggregate
      end

      def update_aggregate(aggregate_id, attributes)
        raise(UpdateAggregateRecordFailed, 'Aggregate update attributes must be a Hash') unless attributes.is_a?(Hash)

        aggregates_collection.find(_id: aggregate_id).update_one('$set' => attributes)
      end

      def save_snapshot(snapshot)
        id = EventSourced::UUID.generate
        attributes = { _id: id, **snapshot }
        snapshots_collection.insert_one(attributes)
        return { id: id.to_s, **snapshot }
      end

      def read_snapshot(snapshot_id)
        snapshot = snapshots_collection.find(_id: snapshot_id).first.symbolize_keys
        snapshot[:id] = snapshot.delete(:_id).to_s
        return snapshot
      end

      def read_last_snapshot(aggregate_id)
        snapshot = snapshots_collection.find(aggregate_id: aggregate_id).sort(created_at: -1).first.symbolize_keys
        snapshot[:id] = snapshot.delete(:_id).to_s
        return snapshot
      end

      def append_command(command)
        result = commands_collection.insert_one(command.to_h)
        return result.n
      end

      def command_stream(aggregate_id)
        commands = commands_collection.find(aggregate_id: aggregate_id).sort(timestamp: 1)

        commands = commands.map do |command|
          c = Hash[command.to_h]
          c.symbolize_keys!
          c[:id] = c.delete(:_id).to_s
          c
        end

        return commands
      end

      def append_event(event)
        result = events_collection.insert_one(event.to_h)
        return result.n
      end

      def append_events(events)
        raise InvalidEventCollection unless events.is_a? Array

        result = events_collection.insert_many(events.map(&:to_h))
        return result.inserted_count
      end

      def event_stream(aggregate_id)
        events = events_collection.find(aggregate_id: aggregate_id).sort(timestamp: 1)

        events = events.map do |event|
          e = Hash[event.to_h]
          e.symbolize_keys!
          e.delete(:_id)
          e
        end

        return events
      end

      def destroy_all!
        events_collection.drop
        commands_collection.drop
        aggregates_collection.drop
        snapshots_collection.drop

        return true
      end

      def destroy_aggregate!(aggregate_id)
        return false unless aggregate_id

        aggregates_collection.delete_one(_id: aggregate_id)
        snapshots_collection.delete_many(aggregate_id: aggregate_id)
        commands_collection.delete_many(aggregate_id: aggregate_id)
        events_collection.delete_many(aggregate_id: aggregate_id)

        return true
      end

      def create_indexes
        Support.create_indexes(
          OpenStruct.new(
            aggregates: aggregates_collection,
            commands:   commands_collection,
            events:     events_collection,
            snapshots:  snapshots_collection
          )
        )
      end

      def create_validators
        Support.create_validators(
          db,
          OpenStruct.new(
            aggregates: aggregates_collection_name,
            commands:   commands_collection_name,
            events:     events_collection_name,
            snapshots:  snapshots_collection_name
          )
        )
      end

      private

      def map_record(record)
        record.to_h.symbolize_keys!
      end

      def map_records(records)
        records.map do |r|
          map_record(r)
        end
      end

      def client
        @client ||= Mongo::Client.new(['127.0.0.1:27017'], database: 'event-store')
      end

      def db
        @db ||= client.database
      end

      def events_collection_name
        @aggregate_name ? "#{@aggregate_name}_events" : 'events'
      end

      def commands_collection_name
        @aggregate_name ? "#{@aggregate_name}_commands" : 'commands'
      end

      def aggregates_collection_name
        @aggregate_name ? "#{@aggregate_name}_aggregates" : 'aggregates'
      end

      def snapshots_collection_name
        @aggregate_name ? "#{@aggregate_name}_snapshots" : 'snapshots'
      end

      def events_collection
        @events_collection ||= client[events_collection_name]
      end

      def commands_collection
        @commands_collection ||= client[commands_collection_name]
      end

      def aggregates_collection
        @aggregates_collection ||= client[aggregates_collection_name]
      end

      def snapshots_collection
        @snapshots_collection ||= client[snapshots_collection_name]
      end
    end
  end
end

require 'event_sourced/event_stores/mongo/support'
