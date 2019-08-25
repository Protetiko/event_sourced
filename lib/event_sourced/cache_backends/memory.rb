# frozen_string_literal: true

require 'date'

module EventSourced
  module CacheBackends
    class MemoryCache
      Entry = Struct.new(:expiry, :value)

      def initialize(opts={})
        @data = Hash.new
        @opts = opts
      end

      def get(key)
        @data[key][:value] if key?(key)
      end

      def key?(key)
        @data.key?(key)
      end

      def put(key, value, ttl = nil)
        ttl ||= @opts[:ttl] || 0
        @data[key] = Entry.new(DateTime.new + Rational(ttl, 1440), value)
        return true
      end

      # def keys
      #   @data.keys
      # end

      # def delete(key)
      #   @data.delete key
      # end

      # def clear
      #   @data = Hash.new
      # end

      # def invalidate
      #   now = DateTime.new
      #   @data.delete_if {|k, v| v[:expiry] < now}
      # end

    end
  end
end