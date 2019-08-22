# frozen_string_literal: true

module EventSourced
  module CacheBackends
    class NullCache
      def key?(key)
        false
      end

      def get(key)
        nil
      end

      def put(key, value, ttl=nil)
        true
      end
    end
  end
end