# frozen_string_literal: true

require 'redis'

module EventSourced
  module CacheBackends
    class Redis
      def initialize(client: nil, opts = {})
        @client = client
      end

      def key?(key)
        @client.key?(key)
      end

      def get(key)
        @client.get(key)
      end

      def put(key, value, ttl=nil)
        @client.put(key, value)
      end
    end
  end
end