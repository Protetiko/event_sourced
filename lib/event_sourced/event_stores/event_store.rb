# frozen_string_literal: true

module EventSourced
  module EventStores
    class EventStore
      MethodNotImplemented        = Class.new(StandardError)
      CreateAggregateRecordFailed = Class.new(StandardError)
      AggregateRecordNotFound     = Class.new(StandardError)
      InvalidEventCollection      = Class.new(StandardError)
      UpdateAggregateRecordFailed = Class.new(StandardError)
      SnapshotNotFound            = Class.new(StandardError)

      def create_aggregate(aggregate)
        raise MethodNotImplemented
      end

      def read_aggregate(aggregate_id)
        raise MethodNotImplemented
      end

      def update_aggregate(aggregate_id, attributes)
        raise MethodNotImplemented
      end

      def save_snapshot(snapshot)
        raise MethodNotImplemented
      end

      def read_snapshot(snapshot_id)
        raise MethodNotImplemented
      end

      def read_last_snapshot(aggregate_id)
        raise MethodNotImplemented
      end

      def append_command(command)
        raise MethodNotImplemented
      end

      def command_stream(aggregate_id)
        raise MethodNotImplemented
      end

      def append_event(event)
          raise MethodNotImplemented
      end

      def append_events(events)
        raise MethodNotImplemented
      end

      def read_stream(aggregate_id)
        raise MethodNotImplemented
      end

      def destroy_all!
        raise MethodNotImplemented
      end

      def destroy_aggregate!(aggregate_id)
        raise MethodNotImplemented
      end
    end
  end
end
