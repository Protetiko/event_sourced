# frozen_string_literal: true

require 'redis'

module EventSourced
  module CacheBackends
    class Redis
      def initialize(client: , **opts)
        @client = client
      end

      def key?(key)
        @client.exists(key)
      end

      def get(key)
        @client.get(key)
      end

      def put(key, value, ttl=nil)
        @client.set(key, value)
      end

      def delete(key)
        @client.del(key)
      end
    end
  end
end
