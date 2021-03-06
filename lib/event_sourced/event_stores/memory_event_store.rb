# frozen_string_literal: true

require 'event_sourced/event_stores/event_store'

module EventSourced
  module EventStores
    class MemoryEventStore < EventStore
      def initialize(_config = {})
        @event_store = {}
        @command_store = {}
        @aggregate_store = {}
        @snapshot_store = {}
      end

      def create_aggregate(attributes)
        raise(CreateAggregateRecordFailed, 'create_aggregate attributes must be a Hash') unless attributes.is_a?(Hash)

        attributes = Hash[attributes]
        id = attributes[:id]
        aggregate_store[id] = attributes
      end

      def read_aggregate(aggregate_id)
        aggregate = aggregate_store[aggregate_id]

        raise AggregateRecordNotFound unless aggregate

        return aggregate
      end

      def update_aggregate(aggregate_id, attributes)
        raise(UpdateAggregateRecordFailed, 'update_aggregate attributes must be a Hash') unless attributes.is_a?(Hash)

        aggregate = aggregate_store[aggregate_id]
        attributes.each_pair do |k, v|
          aggregate[k] = v
        end
      end

      def save_snapshot(snapshot)
        id = EventSourced::UUID.generate
        attributes = { id: id, **snapshot }
        aggregate_id = attributes[:aggregate_id]
        snapshot_store[aggregate_id] = attributes
        return attributes
      end

      def read_snapshot(snapshot_id)
        snapshot = snapshot_store.find {|_, hash| hash[:id] == snapshot_id }[1]

        raise SnapshotNotFound unless snapshot

        return Hash[snapshot]
      end

      def read_last_snapshot(aggregate_id)
        snapshot = snapshot_store[aggregate_id]

        raise SnapshotNotFound unless snapshot

        return Hash[snapshot]
      end

      def append_command(command)
        aggregate_id = command.aggregate_id
        command = command.to_h
        command[:id] = UUID.generate

        if command_store[aggregate_id]
          command_store[aggregate_id] << command
        else
          command_store[aggregate_id] = [command]
        end
      end

      def command_stream(aggregate_id)
        command_store[aggregate_id]
      end

      def append_event(event)
        aggregate_id = event.aggregate_id
        attributes = event.to_h
        attributes[:id] = UUID.generate
        if event_store[aggregate_id]
          event_store[aggregate_id] << attributes
        else
          event_store[aggregate_id] = [attributes]
        end

        return 1
      end

      def append_events(events)
        if events.is_a? Array
          events.each {|e| append_event(e) }
        else
          append_event(events)
        end
      end

      def last_event(aggregate_id)
        event_store[aggregate_id].last

        e = Hash[event.to_h]
        e.symbolize_keys!
        e.delete(:id)

        return e
      end

      def event_stream(aggregate_id, from: 0, to: nil)
        events = event_store[aggregate_id]&.reject {|event|
          event[:sequence_number] < from ||
            (to && event[:sequence_number] > to)
        }&.map { |event|
          e = Hash[event.to_h]
          e.symbolize_keys!
          e.delete(:id)
          e
        }

        return events
      end

      def destroy_all!
        event_store.clear
        command_store.clear
        snapshot_store.clear
        aggregate_store.clear
      end

      def destroy_aggregate!(aggregate_id)
        aggregate_store.delete(aggregate_id)
        command_store.delete(aggregate_id)
        event_store.delete(aggregate_id)
        snapshot_store.delete(aggregate_id)
      end

      def event_store
        @event_store ||= {}
      end

      def command_store
        @command_store ||= {}
      end

      def aggregate_store
        @aggregate_store ||= {}
      end

      def snapshot_store
        @snapshot_store ||= {}
      end
    end
  end
end
