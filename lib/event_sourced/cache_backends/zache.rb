# frozen_string_literal: true

require 'zache'

module EventSourced
  module CacheBackends
    class Zache
      def initialize(**opts)
        @client = ::Zache.new
      end

      def key?(key)
        @client.exists? key
      end

      def get(key)
        @client.get key
      end

      def put(key, value, ttl=nil)
        @client.put(key, value)
      end
    end
  end
end
