# frozen_string_literal: true

module EventSourced
  class Projection
    module Cachable
      CachableCalledWithoutEvent = Class.new(StandardError)

      def self.included(base)
        base.extend(ClassMethods)

        #@cache = EventSourced::Cache.new
      end

      module ClassMethods
        attr_accessor :cache

        def load(aggregate_id, last_event_func = nil, &block)
          projection = cache_get_or_create_projection(aggregate_id) #is the cache preconfigured with the namespace?

          if projection
            last_event = last_event_func.call if last_event_func

            if last_event && projection.sequence_number < last_event.sequence_number
              if block_given? # allow caller to define the loading of the missed events
                events = yield
                projection.apply(events)
                cache_put_projection(projection)
              end
            end
          else
            if block_given? # allow caller to define the loading of the missed events
              projection = self.new
              events = yield
              projection.apply(events)
              cache_put_projection(projection)
            end
          end

          return projection
        end

        def load_and_apply(aggregate_id, event = nil, &block)
          raise CachableCalledWithoutEvent unless event

          projection = cache_get_or_create_projection(event.aggregate_id) #is the cache preconfigured with the namespace?

          if event.sequence_number == projection.sequence_number + 1
            # Great this is the normal case
            if projection.apply(event)
              cache_put_projection(projection)
            end

          elsif event.sequence_number > projection.sequence_number + 1
            # full or partial cache miss, and there is a sequence gap between message.event and projection
            # yield and allow calling method to define how the gap should be filled
            projection = yield(projection) if block_given?

            if projection.sequence_number < event.sequence_number
              # do this check just in case the yield already applied the current event
              if projection.apply(event)
                cache_put_projection(projection)
              end
            end
          end

          return projection
        end

        private

        def cache_put_projection(projection)
          @cache.put(projection.aggregate_id, Marshal.dump(projection))
        end

        def cache_get_or_create_projection(aggregate_id)
          cache_result = @cache.get(aggregate_id)
          projection   = nil

          if cache_result
            # if restore can not be preformed because data format has changed (marshal exception)
            # treat this as a cache miss and delete the cached object
            begin
              projection = Marshal.load(cache_result)
            rescue ArgumentError
              @cache.delete(aggregate_id)
            end
          end

          return projection
        end

      end
    end
  end
end
